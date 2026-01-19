fx_version 'cerulean'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
author 'VORP'
name 'vorp inventory for v-inventory export functions'
description 'VORP Inventory helper for v-inventory'

lua54 'yes'

shared_scripts {
  'config/ammo.lua',
  'config/weapons.lua',
}

client_scripts {
  'client/exports.lua',
}

server_scripts {
  'server/exports.lua',
}
