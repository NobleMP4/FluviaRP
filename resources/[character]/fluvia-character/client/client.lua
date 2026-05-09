-- Client fluvia-character : gestion caméra, ped preview, NUI bridge.

local creationPed = nil
local camHandle   = nil
local isInCreator = false

-- ── Démarrage : demande les slots après initialisation du core ───────────────
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    -- Attendre que le core ait enregistré le joueur
    Wait(2000)
    TriggerNetEvent('fluvia:character:fetchSlots')
end)

-- ── Réception des slots → ouverture du NUI de sélection ─────────────────────
RegisterNetEvent('fluvia:character:receiveSlots', function(slots)
    SetNuiFocus(true, true)
    FreezeEntityPosition(PlayerPedId(), true)
    DisplayHud(false)
    DisplayRadar(false)
    OpenSelectionCamera()
    SendNUIMessage({ action = 'openCharacterSelect', slots = slots, maxSlots = Config.MaxSlots })
end)

-- ── NUI Callbacks ─────────────────────────────────────────────────────────────

-- Joueur sélectionne un personnage existant
RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerNetEvent('fluvia:character:load', data.charId)
    cb({ ok = true })
end)

-- Joueur ouvre le créateur de personnage
RegisterNUICallback('openCreator', function(data, cb)
    isInCreator = true
    local gender = data.gender or 0
    SpawnCreatorPed(gender)
    SendNUIMessage({ action = 'openCreator', slot = data.slot, nationalities = Config.Nationalities })
    cb({ ok = true })
end)

-- Preview en temps réel de l'apparence (slider change)
RegisterNUICallback('previewAppearance', function(data, cb)
    if creationPed and DoesEntityExist(creationPed) then
        ApplyAppearanceToPed(creationPed, data)
    end
    cb({ ok = true })
end)

-- Changement de genre dans le créateur (respawn le ped)
RegisterNUICallback('changeGender', function(data, cb)
    SpawnCreatorPed(data.gender or 0)
    cb({ ok = true })
end)

-- Confirmation de la création du personnage
RegisterNUICallback('createCharacter', function(data, cb)
    TriggerNetEvent('fluvia:character:create', data)
    cb({ ok = true })
end)

-- Annuler le créateur → retour à la sélection
RegisterNUICallback('cancelCreator', function(data, cb)
    isInCreator = false
    if creationPed and DoesEntityExist(creationPed) then
        DeleteEntity(creationPed)
        creationPed = nil
    end
    TriggerNetEvent('fluvia:character:fetchSlots')
    cb({ ok = true })
end)

-- ── Serveur → personnage créé avec succès → charger le personnage ─────────────
RegisterNetEvent('fluvia:character:created', function(charId)
    -- Recharger les slots puis auto-sélectionner le nouveau
    TriggerNetEvent('fluvia:character:load', charId)
end)

-- ── Serveur → spawn du personnage ────────────────────────────────────────────
RegisterNetEvent('fluvia:character:spawn', function(charData)
    -- Fermer le NUI
    SetNuiFocus(false, false)
    FreezeEntityPosition(PlayerPedId(), false)
    DisplayHud(true)
    DisplayRadar(true)
    SendNUIMessage({ action = 'closeAll' })

    -- Fermer la caméra de sélection
    CloseSelectionCamera()

    -- Supprimer le ped de prévisualisation si présent
    if creationPed and DoesEntityExist(creationPed) then
        DeleteEntity(creationPed)
        creationPed = nil
    end

    -- Téléporter le joueur à sa position sauvegardée
    local pos = charData.position
    local ped = PlayerPedId()
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)

    -- Appliquer l'apparence
    ApplyAppearanceToPed(ped, charData.appearance)

    -- Informer les autres ressources (y compris le serveur)
    TriggerEvent('fluvia:characterLoaded', charData)
    TriggerNetEvent('fluvia:characterLoaded', charData)
    TriggerClientEvent('fluvia:notify', -1, nil, nil)  -- pas de notif globale
    TriggerEvent('fluvia:notify', 'success', 'Bienvenue ' .. charData.firstName .. ' ' .. charData.lastName .. ' !')
end)

-- ── Helpers ───────────────────────────────────────────────────────────────────

function OpenSelectionCamera()
    local cp = Config.CreatorCam
    camHandle = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        cp.pos.x, cp.pos.y, cp.pos.z,
        cp.rot.x, cp.rot.y, cp.rot.z,
        cp.fov, true, 0
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
    -- Supprimer l'ancien ped s'il existe
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

    -- Apparence de base (freemode)
    SetPedDefaultComponentVariation(creationPed)
end

-- Applique l'apparence GTA V à un ped
function ApplyAppearanceToPed(ped, app)
    if not app or not DoesEntityExist(ped) then return end

    -- Head blend (mélange de visages parents)
    SetPedHeadBlendData(ped,
        app.parentFaceIndex or 0,   app.parentSkinIndex or 0,   0,
        app.parentFaceIndex or 0,   app.parentSkinIndex or 0,   0,
        app.faceShapeMix    or 0.5, app.skinColorMix    or 0.5, 0.0,
        false
    )

    -- Couleur des yeux
    SetPedEyeColor(ped, app.eyeColor or 0)

    -- Coiffure
    SetPedComponentVariation(ped, 2, app.hairStyle or 0, 0, 0)
    SetPedHairColor(ped, app.hairColor or 0, app.hairHighlightColor or 0)

    -- Overlays : barbe(1), sourcils(2), maquillage(4), taches(11), vieillissement(3), poitrine(10)
    SetPedHeadOverlay(ped, 1,  app.beardStyle      or 255, app.beardOpacity      or 0.0)
    SetPedHeadOverlay(ped, 2,  app.eyebrowStyle    or 0,   app.eyebrowOpacity    or 1.0)
    SetPedHeadOverlay(ped, 3,  app.ageingStyle     or 255, app.ageingOpacity     or 0.0)
    SetPedHeadOverlay(ped, 4,  app.makeupStyle     or 255, app.makeupOpacity     or 0.0)
    SetPedHeadOverlay(ped, 10, app.chestHairStyle  or 255, app.chestHairOpacity  or 0.0)
    SetPedHeadOverlay(ped, 11, app.blemishStyle    or 255, app.blemishOpacity    or 0.0)

    -- Couleurs des overlays
    SetPedHeadOverlayColor(ped, 1,  1, app.beardColor    or 0, 0)
    SetPedHeadOverlayColor(ped, 2,  1, app.eyebrowColor  or 0, 0)
    SetPedHeadOverlayColor(ped, 4,  2, app.makeupColor   or 0, 0)
    SetPedHeadOverlayColor(ped, 10, 1, app.chestHairColor or 0, 0)

    -- Face features (morphologie - 20 indices)
    local features = {
        { key = 'noseWidth',          idx = 0  },
        { key = 'noseHeight',         idx = 1  },
        { key = 'noseBridge',         idx = 2  },
        { key = 'noseTip',            idx = 3  },
        { key = 'noseBridgeShift',    idx = 4  },
        { key = 'browHeight',         idx = 5  },
        { key = 'earSize',            idx = 6  },
        { key = 'lipThickness',       idx = 7  },
        { key = 'jawWidth',           idx = 8  },
        { key = 'jawHeight',          idx = 9  },
        { key = 'chinLength',         idx = 10 },
        { key = 'chinPosition',       idx = 11 },
        { key = 'chinWidth',          idx = 12 },
        { key = 'chinShape',          idx = 13 },
        { key = 'neckThickness',      idx = 14 },
        { key = 'cheekboneHeight',    idx = 15 },
        { key = 'cheekboneWidth',     idx = 16 },
        { key = 'cheeksWidth',        idx = 17 },
        { key = 'eyeOpening',         idx = 18 },
        { key = 'lipThicknessLower',  idx = 19 },
    }
    for _, f in ipairs(features) do
        SetPedFaceFeature(ped, f.idx, app[f.key] or 0.0)
    end
end
