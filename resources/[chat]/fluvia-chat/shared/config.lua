Config = {}

-- Commandes affichées dans le panneau du chat.
-- Elles sont filtrées côté UI (toutes visibles par défaut).
Config.Commands = {
    -- Roleplay
    { cmd = '/me',           desc = 'Action de votre personnage' },
    { cmd = '/do',           desc = 'Description de la scène'    },
    { cmd = '/ooc',          desc = 'Hors personnage (OOC)'      },

    -- Administration (visibles pour tous, exécution refusée côté serveur si non autorisé)
    { cmd = '/kick',         desc = 'Expulser un joueur [admin]'          },
    { cmd = '/ban',          desc = 'Bannir un joueur [admin]'            },
    { cmd = '/noclip',       desc = 'Activer le noclip [admin]'           },
    { cmd = '/god',          desc = 'Mode invincible [admin]'             },
    { cmd = '/tp',           desc = 'Téléportation [admin]'               },
    { cmd = '/spawn',        desc = 'Spawner un véhicule [admin]'         },

    -- Fluvia
    { cmd = '/fluvia_admin_menu',  desc = 'Menu admin (SUPPR)'      },
    { cmd = '/fluvia_tablet',      desc = 'Tablette admin (F8)'     },
}
