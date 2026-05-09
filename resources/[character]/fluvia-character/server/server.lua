-- Serveur fluvia-character : CRUD des personnages, tout validé côté serveur.

local function GetOrCreateInventory(characterId)
    local invId = MySQL.scalar.await(
        "SELECT id FROM inventories WHERE owner_type = 'character' AND owner_id = ?",
        { characterId }
    )
    if not invId then
        invId = MySQL.insert.await(
            "INSERT INTO inventories (owner_type, owner_id) VALUES ('character', ?)",
            { characterId }
        )
    end
    return invId
end

-- ── Récupère les slots de personnage ─────────────────────────────────────────
RegisterNetEvent('fluvia:character:fetchSlots', function()
    local src = source
    local p   = exports['fluvia-core']:GetPlayer(src)
    if not p then return end

    local chars = MySQL.query.await(
        [[SELECT id, slot, first_name, last_name, dob, nationality, gender
          FROM characters
          WHERE player_id = ?
          ORDER BY slot ASC]],
        { p.playerId }
    )

    TriggerClientEvent('fluvia:character:receiveSlots', src, chars or {})
end)

-- ── Charge et spawn un personnage ────────────────────────────────────────────
RegisterNetEvent('fluvia:character:load', function(charId)
    local src = source
    local p   = exports['fluvia-core']:GetPlayer(src)
    if not p then return end

    local chars = MySQL.query.await(
        'SELECT * FROM characters WHERE id = ? AND player_id = ?',
        { charId, p.playerId }
    )

    if not chars or not chars[1] then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Personnage introuvable.')
        return
    end

    local char = chars[1]
    p.characterId = char.id

    local appearance = json.decode(char.appearance) or {}
    local position   = json.decode(char.position)   or Config.DefaultSpawn

    TriggerClientEvent('fluvia:character:spawn', src, {
        id          = char.id,
        firstName   = char.first_name,
        lastName    = char.last_name,
        dob         = tostring(char.dob),
        nationality = char.nationality,
        gender      = char.gender,
        appearance  = appearance,
        position    = position,
    })
end)

-- ── Crée un nouveau personnage ───────────────────────────────────────────────
RegisterNetEvent('fluvia:character:create', function(data)
    local src = source
    local p   = exports['fluvia-core']:GetPlayer(src)
    if not p then return end

    -- Validation du nombre de slots
    local slotCount = MySQL.scalar.await(
        'SELECT COUNT(*) FROM characters WHERE player_id = ?',
        { p.playerId }
    )

    if (slotCount or 0) >= Config.MaxSlots then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Nombre maximum de personnages atteint.')
        return
    end

    -- Validation des champs obligatoires
    if not data.firstName or #data.firstName < 2 or #data.firstName > 50 then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Prénom invalide.')
        return
    end
    if not data.lastName or #data.lastName < 2 or #data.lastName > 50 then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Nom invalide.')
        return
    end
    if not data.dob then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Date de naissance invalide.')
        return
    end

    local nextSlot = (slotCount or 0) + 1

    local charId = MySQL.insert.await(
        [[INSERT INTO characters
          (player_id, slot, first_name, last_name, dob, nationality, gender, appearance)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)]],
        {
            p.playerId,
            nextSlot,
            data.firstName,
            data.lastName,
            data.dob,
            data.nationality or '',
            data.gender or 0,
            json.encode(data.appearance or {}),
        }
    )

    if not charId then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Erreur lors de la création du personnage.')
        return
    end

    -- Créer l'inventaire associé
    GetOrCreateInventory(charId)

    TriggerClientEvent('fluvia:character:created', src, charId)
end)

-- ── Sauvegarde l'apparence en cours de session ───────────────────────────────
RegisterNetEvent('fluvia:character:saveAppearance', function(appearance)
    local src = source
    local p   = exports['fluvia-core']:GetPlayer(src)
    if not p or not p.characterId then return end

    MySQL.update.await(
        'UPDATE characters SET appearance = ? WHERE id = ?',
        { json.encode(appearance), p.characterId }
    )
end)

-- ── Sauvegarde la position à la déconnexion ──────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    local p   = exports['fluvia-core']:GetPlayer(src)
    if not p or not p.characterId then return end

    local ped    = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)
    MySQL.update.await(
        'UPDATE characters SET position = ? WHERE id = ?',
        {
            json.encode({ x = coords.x, y = coords.y, z = coords.z }),
            p.characterId
        }
    )
end)

-- ── Broadcast côté serveur : personnage chargé (pour les autres ressources) ──
RegisterNetEvent('fluvia:characterLoaded', function(charData)
    -- Transmet à toutes les ressources serveur via un event
    TriggerEvent('fluvia:server:characterLoaded', source, charData)
end)
