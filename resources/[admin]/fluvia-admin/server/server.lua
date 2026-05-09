-- Bootstrap serveur fluvia-admin.
-- Les modules (bans, actions) sont chargés avant ce fichier via fxmanifest.
-- Ce fichier sert de point d'entrée et peut contenir des initialisations globales.

print('[FluviaRP Admin] Menu admin chargé.')

-- Vérifie côté serveur si le joueur peut ouvrir le menu avant d'envoyer l'autorisation
RegisterNetEvent('fluvia:admin:requestOpen', function()
    local src = source
    local hasAnyPerm = false
    local nodes = { 'players.kick', 'players.ban', 'players.teleport', 'players.teleport_to_me',
                    'players.god_mode', 'players.info', 'vehicles.spawn', 'vehicles.keys',
                    'noclip', 'god_mode', 'teleport.waypoint', 'factions.manage',
                    'roles.manage', 'server.settings' }
    for _, node in ipairs(nodes) do
        if CheckPerm(src, node) then
            hasAnyPerm = true
            break
        end
    end
    if hasAnyPerm then
        TriggerClientEvent('fluvia:admin:allowOpen', src)
    end
end)
