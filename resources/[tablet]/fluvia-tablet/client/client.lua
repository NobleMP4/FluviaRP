-- Client fluvia-tablet : tablette admin immersive (F8).
-- SetNuiFocus(true, true) → bloque le mouvement et le clavier.

local isOpen = false
local blips  = {}  -- blips de points de service actifs

-- ── Toggle de la tablette ─────────────────────────────────────────────────────
RegisterCommand('fluvia_tablet', function()
    -- Seuls les admins peuvent ouvrir (vérification UI-side + rechargée au besoin)
    ToggleTablet()
end, false)
RegisterKeyMapping('fluvia_tablet', 'Ouvrir la tablette admin', 'keyboard', 'F8')

function ToggleTablet()
    isOpen = not isOpen

    if isOpen then
        SendNUIMessage({ action = 'open' })
        SetNuiFocus(true, true)        -- bloque mouvement ET clavier
        FreezeEntityPosition(PlayerPedId(), true)
        DisplayHud(false)
        DisplayRadar(false)
    else
        SendNUIMessage({ action = 'close' })
        SetNuiFocus(false, false)
        FreezeEntityPosition(PlayerPedId(), false)
        DisplayHud(true)
        DisplayRadar(true)
    end
end

-- ── NUI : fermer la tablette ──────────────────────────────────────────────────
RegisterNUICallback('closeTablet', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)
    FreezeEntityPosition(PlayerPedId(), false)
    DisplayHud(true)
    DisplayRadar(true)
    SendNUIMessage({ action = 'close' })
    cb({ ok = true })
end)

-- ── NUI : Rôles ───────────────────────────────────────────────────────────────
RegisterNUICallback('getRoles', function(data, cb)
    TriggerNetEvent('fluvia:tablet:getRoles')
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:tablet:receiveRoles', function(roles)
    SendNUIMessage({ action = 'roles', data = roles })
end)

RegisterNUICallback('createRole', function(data, cb)
    TriggerNetEvent('fluvia:tablet:createRole', data)
    cb({ ok = true })
end)

RegisterNUICallback('updateRole', function(data, cb)
    TriggerNetEvent('fluvia:tablet:updateRole', data.id, data)
    cb({ ok = true })
end)

RegisterNUICallback('deleteRole', function(data, cb)
    TriggerNetEvent('fluvia:tablet:deleteRole', data.id)
    cb({ ok = true })
end)

RegisterNUICallback('assignRole', function(data, cb)
    TriggerNetEvent('fluvia:tablet:assignRole', data.identifier, data.roleId)
    cb({ ok = true })
end)

RegisterNUICallback('removeRole', function(data, cb)
    TriggerNetEvent('fluvia:tablet:removeRole', data.identifier, data.roleId)
    cb({ ok = true })
end)

-- ── NUI : Factions ────────────────────────────────────────────────────────────
RegisterNUICallback('getFactions', function(data, cb)
    TriggerNetEvent('fluvia:tablet:getFactions')
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:tablet:receiveFactions', function(factions)
    SendNUIMessage({ action = 'factions', data = factions })
end)

RegisterNUICallback('createFaction', function(data, cb)
    TriggerNetEvent('fluvia:tablet:createFaction', data)
    cb({ ok = true })
end)

RegisterNUICallback('updateFaction', function(data, cb)
    TriggerNetEvent('fluvia:tablet:updateFaction', data.id, data)
    cb({ ok = true })
end)

RegisterNUICallback('deleteFaction', function(data, cb)
    TriggerNetEvent('fluvia:tablet:deleteFaction', data.id)
    cb({ ok = true })
end)

-- Grades
RegisterNUICallback('getFactionGrades', function(data, cb)
    TriggerNetEvent('fluvia:tablet:getFactionGrades', data.factionId)
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:tablet:receiveFactionGrades', function(grades)
    SendNUIMessage({ action = 'factionGrades', data = grades })
end)

RegisterNUICallback('addGrade', function(data, cb)
    TriggerNetEvent('fluvia:tablet:addGrade', data.factionId, data.label, data.isBoss)
    cb({ ok = true })
end)

-- Outfits
RegisterNUICallback('getFactionOutfits', function(data, cb)
    TriggerNetEvent('fluvia:tablet:getFactionOutfits', data.factionId)
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:tablet:receiveFactionOutfits', function(outfits)
    SendNUIMessage({ action = 'factionOutfits', data = outfits })
end)

-- Capture la tenue actuelle du ped admin et la sauvegarde
RegisterNUICallback('captureAndSaveOutfit', function(data, cb)
    local ped = PlayerPedId()
    local components = {}

    -- Composants (0-11)
    for comp = 0, 11 do
        components['comp_' .. comp] = {
            drawable  = GetPedDrawableVariation(ped, comp),
            texture   = GetPedTextureVariation(ped, comp),
        }
    end

    -- Props (0-9)
    for prop = 0, 9 do
        components['prop_' .. prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture  = GetPedPropTextureIndex(ped, prop),
        }
    end

    TriggerNetEvent('fluvia:tablet:saveOutfit',
        data.factionId,
        data.gradeId,
        data.label,
        data.gender or 0,
        components
    )
    cb({ ok = true })
end)

-- Points de service
RegisterNUICallback('getFactionServicePoints', function(data, cb)
    TriggerNetEvent('fluvia:tablet:getFactionServicePoints', data.factionId)
    cb({ ok = true })
end)

RegisterNetEvent('fluvia:tablet:receiveFactionServicePoints', function(sps)
    SendNUIMessage({ action = 'factionServicePoints', data = sps })
end)

-- Poser un point de service à la position actuelle de l'admin
RegisterNUICallback('placeServicePoint', function(data, cb)
    local ped     = PlayerPedId()
    local pos     = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TriggerNetEvent('fluvia:tablet:createServicePoint', data.factionId, data.label, {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        h = heading,
    })
    cb({ ok = true })
end)

RegisterNUICallback('deleteServicePoint', function(data, cb)
    TriggerNetEvent('fluvia:tablet:deleteServicePoint', data.id)
    cb({ ok = true })
end)

-- ── Blips des points de service ───────────────────────────────────────────────

local function ClearBlips()
    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function DrawBlips(servicePoints)
    ClearBlips()
    for _, sp in ipairs(servicePoints) do
        local blip = AddBlipForCoord(sp.x, sp.y, sp.z)
        SetBlipSprite(blip, sp.blip_sprite or 1)
        SetBlipColour(blip, sp.blip_color or 0)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(sp.faction_label .. ' - ' .. sp.label)
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
end

-- Reçu du serveur : recharger les blips
RegisterNetEvent('fluvia:factions:refreshBlips', function()
    TriggerNetEvent('fluvia:factions:requestBlips')
end)

RegisterNetEvent('fluvia:factions:receiveBlips', function(sps)
    DrawBlips(sps)
end)

-- Charger les blips au démarrage de la ressource
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(3000)
    TriggerNetEvent('fluvia:factions:requestBlips')
end)

-- Charger les blips quand le personnage est chargé
AddEventHandler('fluvia:characterLoaded', function()
    TriggerNetEvent('fluvia:factions:requestBlips')
end)
