fx_version 'cerulean'
game 'gta5'

name        'fluvia-admin'
description 'FluviaRP - Menu Admin (touche SUPPR) - Overlay sans bloquer le mouvement'
version     '1.0.0'
author      'FluviaRP'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/permissions.lua',
    'server/modules/bans.lua',
    'server/modules/actions.lua',
    'server/server.lua',
}

client_scripts {
    'client/modules/noclip.lua',
    'client/client.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/**',
}
