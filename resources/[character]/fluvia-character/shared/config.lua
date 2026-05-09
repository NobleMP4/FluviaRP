Config = {}

Config.MaxSlots = 3

-- Position de la caméra pour la sélection/création de personnage
-- Caméra placée devant le ped (2.5 m dans la direction où il fait face)
Config.CreatorCam = {
    pos = { x = -264.6, y = -957.4, z = 31.9 },
    rot = { x = -5.0,   y = 0.0,    z = 340.0 },
    fov = 45.0,
}

-- Position du ped de prévisualisation (heading 160 = le ped fait face vers la caméra)
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
