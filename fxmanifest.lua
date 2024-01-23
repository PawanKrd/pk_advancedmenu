fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

name 'pk_advancedmenu'
author 'Pawan.Krd'
description 'A simple and lightweight menu script for FiveM.'
version '1.5'
repository 'https://github.com/PawanKrd/pk_advancedmenu'

-- Client scripts configuration
client_scripts {
    'client.lua',           -- Main client script
    'examples/*.lua'        -- Include all Lua scripts from the 'examples' folder
}