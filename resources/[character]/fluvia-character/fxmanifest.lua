fx_version 'cerulean'
game 'gta5'

name        'fluvia-character'
description 'FluviaRP - Création et sélection de personnage'
version     '1.0.0'
author      'FluviaRP'

dependencies {
    'fluvia-core',
    'spawnmanager',
}

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}

client_scripts {
    'client/client.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/**',
}
