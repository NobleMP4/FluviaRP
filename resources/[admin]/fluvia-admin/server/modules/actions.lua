-- Actions admin validées côté serveur.
-- Chaque event vérifie CheckPerm() en première ligne.

-- ── Liste des joueurs ─────────────────────────────────────────────────────────
RegisterNetEvent('fluvia:admin:requestPlayerList', function()
    local src = source
    if not CheckPerm(src, 'players.info') then return end

    local all  = exports['fluvia-core']:GetAllPlayers()
    local list = {}

    for _, p in ipairs(all) do
        list[#list + 1] = {
            source     = p.source,
            name       = GetPlayerName(p.source),
            identifier = p.identifier,
            ping       = GetPlayerPing(p.source),
            charId     = p.characterId,
        }
    end

    TriggerClientEvent('fluvia:admin:receivePlayerList', src, list)
end)

-- ── Kick ──────────────────────────────────────────────────────────────────────
RegisterNetEvent('fluvia:admin:kick', function(targetSrc, reason)
    local src = source
    if not CheckPerm(src, 'players.kick') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Permission refusée.')
        return
    end

    local targetSrcNum = tonumber(targetSrc)
    if not targetSrcNum or not GetPlayerName(targetSrcNum) then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Joueur introuvable.')
        return
    end

    DropPlayer(targetSrcNum, '[FluviaRP] Vous avez été expulsé. Raison : ' .. (reason or 'Aucune raison'))
    TriggerClientEvent('fluvia:notify', src, 'success', 'Joueur expulsé.')
end)

-- ── Téléportation : admin → joueur ───────────────────────────────────────────
RegisterNetEvent('fluvia:admin:teleportToPlayer', function(targetSrc)
    local src = source
    if not CheckPerm(src, 'players.teleport') then return end

    local targetSrcNum = tonumber(targetSrc)
    if not targetSrcNum then return end

    local targetPed = GetPlayerPed(targetSrcNum)
    if not targetPed or not DoesEntityExist(targetPed) then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Impossible de trouver la position du joueur.')
        return
    end

    local coords = GetEntityCoords(targetPed)
    TriggerClientEvent('fluvia:admin:setCoords', src, coords.x, coords.y, coords.z)
end)

-- ── Téléportation : joueur → admin ───────────────────────────────────────────
RegisterNetEvent('fluvia:admin:teleportPlayerToMe', function(targetSrc)
    local src = source
    if not CheckPerm(src, 'players.teleport_to_me') then return end

    local targetSrcNum = tonumber(targetSrc)
    if not targetSrcNum then return end

    local adminPed = GetPlayerPed(src)
    local coords   = GetEntityCoords(adminPed)
    TriggerClientEvent('fluvia:admin:setCoords', targetSrcNum, coords.x, coords.y, coords.z)
    TriggerClientEvent('fluvia:notify', src, 'success', 'Joueur téléporté à vous.')
end)

-- ── God mode sur un joueur ────────────────────────────────────────────────────
RegisterNetEvent('fluvia:admin:setPlayerGod', function(targetSrc, state)
    local src = source
    if not CheckPerm(src, 'players.god_mode') then return end

    local targetSrcNum = tonumber(targetSrc)
    if not targetSrcNum then return end

    TriggerClientEvent('fluvia:admin:applyGod', targetSrcNum, state)
    TriggerClientEvent('fluvia:notify', src, 'info',
        'God mode ' .. (state and 'activé' or 'désactivé') .. ' sur le joueur.')
end)

-- ── Spawn véhicule (validation côté serveur, spawn côté client) ───────────────
RegisterNetEvent('fluvia:admin:spawnVehicle', function(model)
    local src = source
    if not CheckPerm(src, 'vehicles.spawn') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Permission refusée.')
        return
    end

    -- Valider que le modèle est dans la liste autorisée
    local allowed = false
    for _, v in ipairs(Config.Vehicles) do
        if v.model == model then allowed = true; break end
    end

    if not allowed then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Modèle non autorisé.')
        return
    end

    TriggerClientEvent('fluvia:admin:doSpawnVehicle', src, model)
end)

-- ── Donner une clé de véhicule ────────────────────────────────────────────────
RegisterNetEvent('fluvia:admin:giveVehicleKey', function(targetSrc, plate)
    local src = source
    if not CheckPerm(src, 'vehicles.keys') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Permission refusée.')
        return
    end

    if not plate or #plate < 1 then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Plaque invalide.')
        return
    end

    local targetSrcNum = tonumber(targetSrc)
    local success = exports['fluvia-inventory']:AddItem(targetSrcNum, 'vehicle_key', 1, { plate = plate })

    if success then
        TriggerClientEvent('fluvia:notify', src, 'success', 'Clé donnée pour la plaque : ' .. plate)
    else
        TriggerClientEvent('fluvia:notify', src, 'error', 'Impossible de donner la clé (inventaire plein ?).')
    end
end)
