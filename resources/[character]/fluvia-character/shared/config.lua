Config = {}

Config.MaxSlots = 3

-- Position de la caméra pour la sélection/création de personnage
Config.CreatorCam = {
    pos     = { x = -263.8, y = -956.0, z = 33.5 },
    rot     = { x = 0.0,    y = 0.0,    z = 160.0 },
    fov     = 55.0,
}

-- Position du ped de prévisualisation
Config.CreatorPedPos = { x = -265.5, y = -955.0, z = 31.2, h = 160.0 }

-- Spawn par défaut pour un nouveau personnage
Config.DefaultSpawn = { x = -269.4, y = -955.3, z = 31.2, h = 205.0 }

-- Nationalités disponibles dans le créateur
Config.Nationalities = {
    'Américain(e)', 'Français(e)', 'Espagnol(e)', 'Italien(ne)',
    'Allemand(e)', 'Britannique', 'Mexicain(e)', 'Brésilien(ne)',
    'Canadien(ne)', 'Australien(ne)', 'Japonais(e)', 'Chinois(e)',
    'Russe', 'Autre',
}
