-- CRUD des rôles admin + assignation de rôle à un joueur.

-- ── Récupérer tous les rôles ──────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:getRoles', function()
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    local roles = MySQL.query.await('SELECT * FROM admin_roles ORDER BY id ASC', {})
    TriggerClientEvent('fluvia:tablet:receiveRoles', src, roles or {})
end)

-- ── Créer un rôle ─────────────────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:createRole', function(data)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    if not data or not data.name or not data.label then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Données invalides.')
        return
    end

    -- Sanitiser le nom (alphanumeric + underscore uniquement)
    if not data.name:match('^[a-zA-Z0-9_]+$') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Le nom du rôle ne peut contenir que des lettres, chiffres et underscores.')
        return
    end

    local perms = json.encode(data.permissions or {})
    local roleId = MySQL.insert.await(
        'INSERT INTO admin_roles (name, label, permissions) VALUES (?, ?, ?)',
        { data.name:lower(), data.label, perms }
    )

    if roleId then
        TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle créé : ' .. data.label)
        local roles = MySQL.query.await('SELECT * FROM admin_roles ORDER BY id ASC', {})
        TriggerClientEvent('fluvia:tablet:receiveRoles', src, roles or {})
    else
        TriggerClientEvent('fluvia:notify', src, 'error', 'Ce nom de rôle existe déjà.')
    end
end)

-- ── Mettre à jour un rôle ─────────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:updateRole', function(roleId, data)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    if not roleId or not data then return end

    -- Empêcher la modification du superadmin wildcard
    local roleName = MySQL.scalar.await('SELECT name FROM admin_roles WHERE id = ?', { roleId })
    if roleName == 'superadmin' then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Impossible de modifier le rôle superadmin.')
        return
    end

    MySQL.update.await(
        'UPDATE admin_roles SET label = ?, permissions = ? WHERE id = ?',
        { data.label, json.encode(data.permissions or {}), roleId }
    )

    -- Recharger les permissions des joueurs ayant ce rôle (en mémoire)
    local assignments = MySQL.query.await(
        'SELECT aa.player_id FROM admin_assignments aa WHERE aa.role_id = ?',
        { roleId }
    )
    if assignments then
        local allPlayers = exports['fluvia-core']:GetAllPlayers()
        for _, p in ipairs(allPlayers) do
            for _, a in ipairs(assignments) do
                if p.playerId == a.player_id then
                    p:LoadPermissions()
                    break
                end
            end
        end
    end

    TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle mis à jour.')
end)

-- ── Supprimer un rôle ─────────────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:deleteRole', function(roleId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    local roleName = MySQL.scalar.await('SELECT name FROM admin_roles WHERE id = ?', { roleId })
    if roleName == 'superadmin' or roleName == 'admin' then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Impossible de supprimer ce rôle par défaut.')
        return
    end

    MySQL.update.await('DELETE FROM admin_roles WHERE id = ?', { roleId })
    TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle supprimé.')
end)

-- ── Assigner un rôle à un joueur (par identifier) ────────────────────────────
RegisterNetEvent('fluvia:tablet:assignRole', function(identifier, roleId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    -- Trouver le playerId depuis l'identifier
    local playerId = MySQL.scalar.await(
        'SELECT id FROM players WHERE identifier = ?',
        { identifier }
    )

    if not playerId then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Joueur introuvable (identifier non trouvé en DB).')
        return
    end

    local adminP = exports['fluvia-core']:GetPlayer(src)
    MySQL.insert.await(
        [[INSERT IGNORE INTO admin_assignments (player_id, role_id, assigned_by)
          VALUES (?, ?, ?)]],
        { playerId, roleId, adminP and adminP.playerId or nil }
    )

    -- Si le joueur est en ligne, recharger ses permissions immédiatement
    local targetPlayer = exports['fluvia-core']:GetPlayerByIdentifier(identifier)
    if targetPlayer then
        targetPlayer:LoadPermissions()
        TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle assigné et permissions rechargées.')
    else
        TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle assigné (joueur hors ligne, actif à la prochaine connexion).')
    end
end)

-- ── Retirer un rôle d'un joueur ───────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:removeRole', function(identifier, roleId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'roles.manage') then return end

    local playerId = MySQL.scalar.await(
        'SELECT id FROM players WHERE identifier = ?',
        { identifier }
    )
    if not playerId then return end

    MySQL.update.await(
        'DELETE FROM admin_assignments WHERE player_id = ? AND role_id = ?',
        { playerId, roleId }
    )

    local targetPlayer = exports['fluvia-core']:GetPlayerByIdentifier(identifier)
    if targetPlayer then
        targetPlayer:LoadPermissions()
    end

    TriggerClientEvent('fluvia:notify', src, 'success', 'Rôle retiré.')
end)
