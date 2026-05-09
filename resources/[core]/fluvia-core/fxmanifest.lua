fx_version 'cerulean'
game 'gta5'

name        'fluvia-core'
description 'FluviaRP - Core Framework'
version     '1.0.0'
author      'FluviaRP'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/database.lua',
    'server/modules/players.lua',
    'server/server.lua',
}

client_scripts {
    'client/client.lua',
}

server_exports {
    'GetPlayer',
    'EnsurePlayer',
    'GetAllPlayers',
    'GetPlayerByIdentifier',
    'HasPermission',
}
