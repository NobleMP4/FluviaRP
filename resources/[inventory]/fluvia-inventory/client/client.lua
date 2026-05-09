-- Client inventaire : notifications de réception d'items.

-- Notification quand un item est ajouté à l'inventaire
RegisterNetEvent('fluvia:inventory:itemAdded', function(data)
    -- Notification simple
    TriggerEvent('fluvia:notify', 'success', 'Vous avez reçu : ' .. (data.label or data.itemName))

    -- Si c'est une clé de véhicule, l'ajouter à la liste locale des clés
    if data.itemName == 'vehicle_key' and data.metadata and data.metadata.plate then
        TriggerEvent('fluvia:vehicleKeys:add', data.metadata.plate)
    end
end)

-- Gestion locale des clés de véhicules
local vehicleKeys = {}

AddEventHandler('fluvia:vehicleKeys:add', function(plate)
    vehicleKeys[plate] = true
end)

-- Vérifie si le joueur possède la clé d'un véhicule (utilisé par d'autres ressources)
function HasVehicleKey(plate)
    return vehicleKeys[plate] == true
end

-- Vérification des véhicules à portée et déverrouillage si clé possédée
CreateThread(function()
    while true do
        Wait(1000)
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local vehicles = {}
        local veh = GetFirstVehicle()
        while veh ~= 0 do
            local vehCoords = GetEntityCoords(veh)
            local dist = #(coords - vehCoords)
            if dist < 5.0 then
                local plate = GetVehicleNumberPlateText(veh)
                if vehicleKeys[plate] then
                    -- Le joueur a la clé : ne pas bloquer (déverrouiller si verrouillé)
                    -- Note : la gestion complète du verrouillage sera dans un module dédié
                end
            end
            veh = GetNextVehicle(veh)
        end
    end
end)
