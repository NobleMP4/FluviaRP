fx_version 'cerulean'
game 'gta5'

name        'fluvia-tablet'
description 'FluviaRP - Tablette Admin (F8) - Gestion rôles & factions'
version     '1.0.0'
author      'FluviaRP'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/roles.lua',
    'server/modules/factions.lua',
    'server/server.lua',
}

client_scripts {
    'client/client.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/**',
}
