Config = {}

-- Nombre maximum de slots de personnage par joueur
Config.MaxCharacterSlots = 3

-- Position de spawn par défaut (première connexion / premier personnage)
Config.DefaultSpawn = { x = -269.4, y = -955.3, z = 31.2, h = 205.0 }

-- Liste authoritative de tous les nodes de permission
-- Utilisée par la tablette admin pour afficher les cases à cocher
Config.Permissions = {
    { node = 'players.kick',            label = 'Kicker des joueurs'         },
    { node = 'players.ban',             label = 'Bannir des joueurs'         },
    { node = 'players.teleport',        label = 'Se téléporter à un joueur'  },
    { node = 'players.teleport_to_me',  label = 'Téléporter un joueur à soi' },
    { node = 'players.god_mode',        label = 'God mode sur joueurs'       },
    { node = 'players.info',            label = 'Voir infos joueurs'         },
    { node = 'vehicles.spawn',          label = 'Spawner des véhicules'      },
    { node = 'vehicles.keys',           label = 'Donner des clés de véhicule'},
    { node = 'noclip',                  label = 'Noclip'                     },
    { node = 'god_mode',                label = 'God mode personnel'         },
    { node = 'teleport.waypoint',       label = 'TP au waypoint'             },
    { node = 'factions.manage',         label = 'Gérer les factions'         },
    { node = 'roles.manage',            label = 'Gérer les rôles admin'      },
    { node = 'server.settings',         label = 'Paramètres serveur'         },
}

-- Wildcard superadmin
Config.SuperadminWildcard = '*'
