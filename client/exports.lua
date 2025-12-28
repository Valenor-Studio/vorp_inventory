-- exports

exports('closeInventory', function()
    return exports["v-inventory"]:closeInventory()
end)

exports('getWeaponDefaultWeight', function(hash)
    return nil
end)

exports('getWeaponDefaultDesc', function(hash)
    return nil
end)

exports('getWeaponDefaultLabel', function(hash)
    return nil
end)

exports('getWeaponName', function(hash)
    return nil
end)

exports('getWeaponsDefaultData', function(request)
    return nil
end)

exports('getWeaponAmmoTypes', function(group)
    return nil
end)

exports('getAmmoLabel', function(ammo)
    return nil
end)

exports('getInventoryItem', function(name)
    return exports["v-inventory"]:getInventoryItem(name)
end)

exports('getInventoryItems', function()
    return exports["v-inventory"]:getInventoryItems()
end)

exports("getServerItem", function(data)
    return nil
end)

exports("useWeapon", function() return nil end)

exports("useItem", function() return nil end)