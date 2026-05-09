export interface AdminRole {
  id: number
  name: string
  label: string
  permissions: string  // JSON string from DB
  created_at?: string
}

export interface Faction {
  id: number
  name: string
  label: string
  type: string
  blip_sprite: number
  blip_color: number
  member_count: number
}

export interface FactionGrade {
  id: number
  faction_id: number
  grade: number
  label: string
  is_boss: 0 | 1
}

export interface FactionOutfit {
  id: number
  faction_id: number
  grade_id: number | null
  label: string
  gender: 0 | 1
  components: string  // JSON string
}

export interface ServicePoint {
  id: number
  faction_id: number
  label: string
  x: number
  y: number
  z: number
  heading: number
}

export const ALL_PERMISSIONS = [
  { node: 'players.kick',           label: 'Kicker des joueurs'          },
  { node: 'players.ban',            label: 'Bannir des joueurs'          },
  { node: 'players.teleport',       label: 'Se téléporter à un joueur'   },
  { node: 'players.teleport_to_me', label: 'Téléporter un joueur à soi'  },
  { node: 'players.god_mode',       label: 'God mode sur joueurs'        },
  { node: 'players.info',           label: 'Voir infos joueurs'          },
  { node: 'vehicles.spawn',         label: 'Spawner des véhicules'       },
  { node: 'vehicles.keys',          label: 'Donner des clés de véhicule' },
  { node: 'noclip',                 label: 'Noclip'                      },
  { node: 'god_mode',               label: 'God mode personnel'          },
  { node: 'teleport.waypoint',      label: 'TP au waypoint'              },
  { node: 'factions.manage',        label: 'Gérer les factions'          },
  { node: 'roles.manage',           label: 'Gérer les rôles admin'       },
  { node: 'server.settings',        label: 'Paramètres serveur'          },
]
