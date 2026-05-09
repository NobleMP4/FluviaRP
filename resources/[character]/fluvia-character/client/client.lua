-- Client fluvia-character : gestion caméra, ped preview, NUI bridge.

local creationPed = nil
local camHandle   = nil
local isInCreator = false

-- ── Démarrage : demande les slots après initialisation du core ───────────────
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(2000)
    TriggerServerEvent('fluvia:character:fetchSlots')
end)

-- ── Réception des slots → ouverture du NUI de sélection ─────────────────────
RegisterNetEvent('fluvia:character:receiveSlots', function(slots)
    exports.spawnmanager:spawnPlayer({
        x        = -269.4,
        y        = -955.3,
        z        = 31.2,
        heading  = 0.0,
        model    = GetHashKey('mp_m_freemode_01'),
        skipFade = true,
    }, function()
        SetNuiFocus(true, true)
        FreezeEntityPosition(PlayerPedId(), true)
        DisplayHud(false)
        DisplayRadar(false)
        OpenSelectionCamera()
        SendNUIMessage({ action = 'openCharacterSelect', slots = slots, maxSlots = Config.MaxSlots })
    end)
end)

-- ── NUI Callbacks ─────────────────────────────────────────────────────────────

RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerServerEvent('fluvia:character:load', data.charId)
    cb({ ok = true })
end)

RegisterNUICallback('openCreator', function(data, cb)
    isInCreator = true
    local gender = data.gender or 0
    SpawnCreatorPed(gender)
    SendNUIMessage({ action = 'openCreator', slot = data.slot, nationalities = Config.Nationalities })
    cb({ ok = true })
end)

RegisterNUICallback('previewAppearance', function(data, cb)
    if creationPed and DoesEntityExist(creationPed) then
        ApplyAppearanceToPed(creationPed, data)
    end
    cb({ ok = true })
end)

RegisterNUICallback('changeGender', function(data, cb)
    SpawnCreatorPed(data.gender or 0)
    cb({ ok = true })
end)

RegisterNUICallback('createCharacter', function(data, cb)
    TriggerServerEvent('fluvia:character:create', data)
    cb({ ok = true })
end)

RegisterNUICallback('cancelCreator', function(data, cb)
    isInCreator = false
    if creationPed and DoesEntityExist(creationPed) then
        DeleteEntity(creationPed)
        creationPed = nil
    end
    TriggerServerEvent('fluvia:character:fetchSlots')
    cb({ ok = true })
end)

-- ── Serveur → personnage créé → charger directement ──────────────────────────
RegisterNetEvent('fluvia:character:created', function(charId)
    TriggerServerEvent('fluvia:character:load', charId)
end)

-- ── Serveur → spawn du personnage ────────────────────────────────────────────
RegisterNetEvent('fluvia:character:spawn', function(charData)
    SetNuiFocus(false, false)
    FreezeEntityPosition(PlayerPedId(), false)
    DisplayHud(true)
    DisplayRadar(true)
    SendNUIMessage({ action = 'closeAll' })
    CloseSelectionCamera()

    if creationPed and DoesEntityExist(creationPed) then
        DeleteEntity(creationPed)
        creationPed = nil
    end

    local pos = charData.position
    local ped = PlayerPedId()
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)
    FreezeEntityPosition(ped, false)
    ApplyAppearanceToPed(ped, charData.appearance)

    TriggerEvent('fluvia:characterLoaded', charData)
    TriggerServerEvent('fluvia:characterLoaded', charData)
    TriggerEvent('fluvia:notify', 'success', 'Bienvenue ' .. charData.firstName .. ' ' .. charData.lastName .. ' !')
end)

-- ── Helpers ───────────────────────────────────────────────────────────────────

function OpenSelectionCamera()
    -- Caméra initiale (avant spawn du ped) — position quelconque, sera ré-attachée
    local cp = Config.CreatorCam
    camHandle = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        cp.pos.x, cp.pos.y, cp.pos.z,
        0.0, 0.0, 0.0,
        Config.CreatorCam.fov, true, 0
    )
    SetCamActive(camHandle, true)
    RenderScriptCams(true, false, 0, true, false)
end

function CloseSelectionCamera()
    RenderScriptCams(false, false, 0, true, false)
    if camHandle then
        DestroyCam(camHandle, false)
        camHandle = nil
    end
end

function SpawnCreatorPed(gender)
    if creationPed and DoesEntityExist(creationPed) then
        DeleteEntity(creationPed)
        creationPed = nil
    end

    local model = (gender == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01'
    local hash  = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local cp = Config.CreatorPedPos
    creationPed = CreatePed(4, hash, cp.x, cp.y, cp.z, cp.h, false, true)

    SetEntityInvincible(creationPed, true)
    FreezeEntityPosition(creationPed, true)
    SetEntityVisible(creationPed, true, false)
    SetBlockingOfNonTemporaryEvents(creationPed, true)
    SetModelAsNoLongerNeeded(hash)
    SetPedDefaultComponentVariation(creationPed)

    -- Attacher la caméra au ped en espace local :
    -- yOffset positif = devant le ped (dans la direction qu'il regarde)
    -- zOffset = hauteur du visage
    -- Puis PointCamAtEntity pour qu'elle regarde vers le ped → vue de face
    if camHandle then
        AttachCamToEntity(camHandle, creationPed, 0.0, 2.5, 0.7, true)
        PointCamAtEntity(camHandle, creationPed, 0.0, 0.0, 0.65, true)
    end
end

-- Applique l'apparence GTA V à un ped
function ApplyAppearanceToPed(ped, app)
    if not app or not DoesEntityExist(ped) then return end

    SetPedHeadBlendData(ped,
        app.parentFaceIndex or 0,   app.parentSkinIndex or 0,   0,
        app.parentFaceIndex or 0,   app.parentSkinIndex or 0,   0,
        app.faceShapeMix    or 0.5, app.skinColorMix    or 0.5, 0.0,
        false
    )

    SetPedEyeColor(ped, app.eyeColor or 0)
    SetPedComponentVariation(ped, 2, app.hairStyle or 0, 0, 0)
    SetPedHairColor(ped, app.hairColor or 0, app.hairHighlightColor or 0)

    SetPedHeadOverlay(ped, 1,  app.beardStyle      or 255, app.beardOpacity      or 0.0)
    SetPedHeadOverlay(ped, 2,  app.eyebrowStyle    or 0,   app.eyebrowOpacity    or 1.0)
    SetPedHeadOverlay(ped, 3,  app.ageingStyle     or 255, app.ageingOpacity     or 0.0)
    SetPedHeadOverlay(ped, 4,  app.makeupStyle     or 255, app.makeupOpacity     or 0.0)
    SetPedHeadOverlay(ped, 10, app.chestHairStyle  or 255, app.chestHairOpacity  or 0.0)
    SetPedHeadOverlay(ped, 11, app.blemishStyle    or 255, app.blemishOpacity    or 0.0)

    SetPedHeadOverlayColor(ped, 1,  1, app.beardColor     or 0, 0)
    SetPedHeadOverlayColor(ped, 2,  1, app.eyebrowColor   or 0, 0)
    SetPedHeadOverlayColor(ped, 4,  2, app.makeupColor    or 0, 0)
    SetPedHeadOverlayColor(ped, 10, 1, app.chestHairColor or 0, 0)

    local features = {
        { key = 'noseWidth',         idx = 0  },
        { key = 'noseHeight',        idx = 1  },
        { key = 'noseBridge',        idx = 2  },
        { key = 'noseTip',           idx = 3  },
        { key = 'noseBridgeShift',   idx = 4  },
        { key = 'browHeight',        idx = 5  },
        { key = 'earSize',           idx = 6  },
        { key = 'lipThickness',      idx = 7  },
        { key = 'jawWidth',          idx = 8  },
        { key = 'jawHeight',         idx = 9  },
        { key = 'chinLength',        idx = 10 },
        { key = 'chinPosition',      idx = 11 },
        { key = 'chinWidth',         idx = 12 },
        { key = 'chinShape',         idx = 13 },
        { key = 'neckThickness',     idx = 14 },
        { key = 'cheekboneHeight',   idx = 15 },
        { key = 'cheekboneWidth',    idx = 16 },
        { key = 'cheeksWidth',       idx = 17 },
        { key = 'eyeOpening',        idx = 18 },
        { key = 'lipThicknessLower', idx = 19 },
    }
    for _, f in ipairs(features) do
        SetPedFaceFeature(ped, f.idx, app[f.key] or 0.0)
    end
end
