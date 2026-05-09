-- Client bootstrap de fluvia-core.
-- Attend le chargement du personnage, puis expose les données locales.

local localCharacter = nil
local isLoaded       = false

-- Reçu depuis fluvia-character après qu'un personnage est chargé
AddEventHandler('fluvia:characterLoaded', function(charData)
    isLoaded       = true
    localCharacter = charData
    print('[FluviaRP Core] Personnage chargé : ' .. charData.firstName .. ' ' .. charData.lastName)
end)

-- Exposition locale pour les autres ressources (client-side)
function FluviaGetCharacter()
    return localCharacter
end

function FluviaIsLoaded()
    return isLoaded
end

-- Notification client (appelée via TriggerClientEvent depuis le serveur)
-- type: 'success' | 'error' | 'info' | 'warning'
RegisterNetEvent('fluvia:notify', function(notifType, message)
    -- Affichage simple via le chat natif FiveM pour l'instant
    -- Peut être remplacé par un système de notification custom React
    local colors = {
        success = '~g~',
        error   = '~r~',
        info    = '~b~',
        warning = '~y~',
    }
    local color = colors[notifType] or '~w~'
    SetNotificationTextEntry('STRING')
    AddTextComponentString(color .. message)
    DrawNotification(false, true)
end)
