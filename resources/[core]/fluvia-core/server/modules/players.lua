-- Registre en mémoire des joueurs connectés.
-- Chaque ressource appelle exports['fluvia-core']:GetPlayer(src) pour accéder à l'objet Player.

Players = {}

-- Constructeur d'objet Player
local function NewPlayer(src, identifier, playerId)
    local self = {
        source      = src,
        identifier  = identifier,
        playerId    = playerId,
        characterId = nil,
        permissions = {},  -- nodes de permission mis en cache pour cette session
    }

    -- Vérifie si le joueur possède un node de permission
    function self:HasPermission(node)
        if self.permissions[Config.SuperadminWildcard] then return true end
        return self.permissions[node] == true
    end

    -- Charge/recharge les permissions depuis la DB
    function self:LoadPermissions()
        local rows = MySQL.query.await(
            [[SELECT ar.permissions
              FROM admin_assignments aa
              JOIN admin_roles ar ON ar.id = aa.role_id
              WHERE aa.player_id = ?]],
            { self.playerId }
        )

        self.permissions = {}

        if not rows then return end

        for _, row in ipairs(rows) do
            local perms = json.decode(row.permissions) or {}
            for _, perm in ipairs(perms) do
                if perm == Config.SuperadminWildcard then
                    -- Wildcard : toutes les permissions
                    self.permissions[Config.SuperadminWildcard] = true
                    return
                end
                self.permissions[perm] = true
            end
        end
    end

    return self
end

-- Enregistre un joueur lors de sa connexion
function Players.Register(src)
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then
        identifier = GetPlayerIdentifierByType(src, 'steam')
    end

    if not identifier then
        DropPlayer(src, '[FluviaRP] Aucun identifiant valide trouvé. Merci de rejoindre avec Steam ou une licence FiveM.')
        return nil
    end

    -- Upsert joueur dans la DB
    local playerId = MySQL.scalar.await(
        'SELECT id FROM players WHERE identifier = ?',
        { identifier }
    )

    if not playerId then
        playerId = MySQL.insert.await(
            'INSERT INTO players (identifier) VALUES (?)',
            { identifier }
        )
    else
        MySQL.update.await(
            'UPDATE players SET last_seen = NOW() WHERE id = ?',
            { playerId }
        )
    end

    if not playerId then
        print('[FluviaRP Core] ERREUR : impossible de créer/trouver le joueur ' .. identifier)
        return nil
    end

    local player = NewPlayer(src, identifier, playerId)
    player:LoadPermissions()

    Players[src] = player
    print('[FluviaRP Core] Joueur enregistré : ' .. GetPlayerName(src) .. ' (' .. identifier .. ')')
    return player
end

-- Supprime un joueur du registre
function Players.Remove(src)
    Players[src] = nil
end

-- Récupère un joueur par source
function Players.Get(src)
    return Players[src]
end

-- Récupère tous les joueurs
function Players.GetAll()
    local list = {}
    for _, p in pairs(Players) do
        list[#list + 1] = p
    end
    return list
end

-- Récupère un joueur par son identifier
function Players.GetByIdentifier(identifier)
    for _, p in pairs(Players) do
        if p.identifier == identifier then
            return p
        end
    end
    return nil
end
