fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'ui/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/*.lua'
}

client_scripts{
    'client/*.lua'
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'ui/weapons/**',
    'ui/dist/**'
}

escrow_ignore {
    'shared/*.lua'
}

dependency '/assetpacks'