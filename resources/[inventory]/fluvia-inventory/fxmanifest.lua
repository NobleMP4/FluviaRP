fx_version 'cerulean'
game 'gta5'

name        'fluvia-inventory'
description 'FluviaRP - Système d\'inventaire'
version     '1.0.0'
author      'FluviaRP'

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

server_exports {
    'AddItem',
    'RemoveItem',
    'GetInventory',
    'HasItem',
}
