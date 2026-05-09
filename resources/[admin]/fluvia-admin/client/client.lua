-- Client fluvia-admin : menu overlay (SUPPR), ne bloque PAS le mouvement.
-- SetNuiFocus(true, false) = souris capturée, clavier libre = joueur peut se déplacer.

local isMenuOpen = false
local isGodMode  = false

-- ── Toggle du menu ────────────────────────────────────────────────────────────
RegisterCommand('fluvia_admin_menu', function()
    ToggleMenu()
end, false)
RegisterKeyMapping('fluvia_admin_menu', 'Ouvrir le menu admin', 'keyboard', 'DELETE')

function ToggleMenu()
    isMenuOpen = not isMenuOpen

    if isMenuOpen then
        SendNUIMessage({ action = 'open' })
        SetNuiFocus(true, true)
        TriggerServerEvent('fluvia:admin:requestPlayerList')
    else
        SendNUIMessage({ action = 'close' })
        SetNuiFocus(false, false)
    end
end

-- ── NUI : fermer le menu ──────────────────────────────────────────────────────
RegisterNUICallback('closeMenu', function(data, cb)
    isMenuOpen = false
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- ── NUI : liste des joueurs ───────────────────────────────────────────────────
RegisterNUICallback('requestPlayerList', function(data, cb)
    TriggerServerEvent('fluvia:admin:requestPlayerList')
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:admin:receivePlayerList', function(list)
    SendNUIMessage({ action = 'playerList', data = list })
end)

-- ── NUI : actions sur un joueur ────────────────────────────────────────────────
RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('fluvia:admin:kick', data.source, data.reason)
    cb({ ok = true })
end)

RegisterNUICallback('banPlayer', function(data, cb)
    TriggerServerEvent('fluvia:admin:ban', data.source, data.reason, data.duration)
    cb({ ok = true })
end)

RegisterNUICallback('teleportToPlayer', function(data, cb)
    TriggerServerEvent('fluvia:admin:teleportToPlayer', data.source)
    cb({ ok = true })
end)

RegisterNUICallback('teleportPlayerToMe', function(data, cb)
    TriggerServerEvent('fluvia:admin:teleportPlayerToMe', data.source)
    cb({ ok = true })
end)

RegisterNUICallback('setPlayerGod', function(data, cb)
    TriggerServerEvent('fluvia:admin:setPlayerGod', data.source, data.state)
    cb({ ok = true })
end)

RegisterNUICallback('giveVehicleKey', function(data, cb)
    TriggerServerEvent('fluvia:admin:giveVehicleKey', data.source, data.plate)
    cb({ ok = true })
end)

-- ── NUI : actions rapides ──────────────────────────────────────────────────────
RegisterNUICallback('toggleNoclip', function(data, cb)
    local state = ToggleNoclip()
    SendNUIMessage({ action = 'noclipState', state = state })
    TriggerEvent('fluvia:notify', state and 'info' or 'warning', 'Noclip ' .. (state and 'activé' or 'désactivé'))
    cb({ ok = true })
end)

RegisterNUICallback('toggleSelfGod', function(data, cb)
    isGodMode = not isGodMode
    SetEntityInvincible(PlayerPedId(), isGodMode)
    SendNUIMessage({ action = 'godState', state = isGodMode })
    TriggerEvent('fluvia:notify', isGodMode and 'info' or 'warning', 'God mode ' .. (isGodMode and 'activé' or 'désactivé'))
    cb({ ok = true })
end)

RegisterNUICallback('teleportToWaypoint', function(data, cb)
    local blip = GetFirstBlipInfoId(8)  -- type 8 = waypoint

    if not DoesBlipExist(blip) then
        TriggerEvent('fluvia:notify', 'error', 'Aucun waypoint défini sur la carte.')
        cb({ ok = false })
        return
    end

    local coords = GetBlipInfoIdCoord(blip)

    -- Raycast vers le bas pour trouver le sol
    local startZ  = coords.z + 200.0
    local endZ    = coords.z - 200.0
    local ray     = StartShapeTestRay(coords.x, coords.y, startZ, coords.x, coords.y, endZ, 1, PlayerPedId(), 0)
    local _, hit, hitCoords = GetShapeTestResult(ray)
    local finalZ  = (hit and hitCoords.z or coords.z) + 0.5

    SetEntityCoords(PlayerPedId(), coords.x, coords.y, finalZ, false, false, false, false)
    TriggerEvent('fluvia:notify', 'success', 'Téléporté au waypoint.')
    cb({ ok = true })
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerServerEvent('fluvia:admin:spawnVehicle', data.model)
    cb({ ok = true })
end)

RegisterNUICallback('getVehicleList', function(data, cb)
    cb({ ok = true, vehicles = Config.Vehicles })
end)

-- ── Serveur → client : téléporter le joueur ──────────────────────────────────
RegisterNetEvent('fluvia:admin:setCoords', function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z + 1.0, false, false, false, false)
end)

-- ── Serveur → client : appliquer god mode ────────────────────────────────────
RegisterNetEvent('fluvia:admin:applyGod', function(state)
    SetEntityInvincible(PlayerPedId(), state)
end)

-- ── Serveur → client : spawner le véhicule ────────────────────────────────────
RegisterNetEvent('fluvia:admin:doSpawnVehicle', function(model)
    local hash = GetHashKey(model)
    RequestModel(hash)

    while not HasModelLoaded(hash) do Wait(10) end

    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Spawner légèrement en avant du joueur
    local spawnX = coords.x + math.sin(-math.rad(heading)) * 5.0
    local spawnY = coords.y + math.cos(-math.rad(heading)) * 5.0

    local veh = CreateVehicle(hash, spawnX, spawnY, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, veh, -1)
    SetModelAsNoLongerNeeded(hash)

    TriggerEvent('fluvia:notify', 'success', 'Véhicule spawné : ' .. model)
end)
