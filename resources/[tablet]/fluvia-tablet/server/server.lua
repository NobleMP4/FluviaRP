-- Bootstrap serveur fluvia-tablet.
-- Les modules roles.lua et factions.lua sont chargés avant ce fichier.

print('[FluviaRP Tablet] Tablette admin chargée.')

-- Vérifie les perms avant d'autoriser l'ouverture de la tablette
RegisterNetEvent('fluvia:tablet:requestOpen', function()
    local src = source
    local allowed = exports['fluvia-core']:HasPermission(src, 'factions.manage')
                 or exports['fluvia-core']:HasPermission(src, 'roles.manage')
    if allowed then
        TriggerClientEvent('fluvia:tablet:allowOpen', src)
    end
end)
