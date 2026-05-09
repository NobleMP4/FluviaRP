Config = {}

Config.MaxSlots = 30

-- Définition des items disponibles
Config.Items = {
    vehicle_key = {
        label  = 'Clé de véhicule',
        weight = 0.1,
        usable = false,
        icon   = 'key',
        -- La plaque du véhicule est stockée dans metadata.plate
    },
    -- D'autres items peuvent être ajoutés ici
}
