-- exports

exports('closeInventory', function()
    --print("export:closeInventory")
    return exports["v-inventory"]:closeInventory()
end)

exports('getWeaponDefaultWeight', function(hash)
    --print("export:getWeaponDefaultWeight")
    if not hash then return 0.0 end
    for name, data in pairs(Config.Weapons) do
        if GetHashKey(name) == hash then
            return data.Weight or 0.0
        end
    end
    return 0.0
end)

exports('getWeaponDefaultDesc', function(hash)
    --print("export:getWeaponDefaultDesc")
    if not hash then return "" end
    for name, data in pairs(Config.Weapons) do
        if GetHashKey(name) == hash then
            return data.Label or "" -- Description not explicitly in Config, fallback to Label or empty
        end
    end
    return ""
end)

exports('getWeaponDefaultLabel', function(hash)
    --print("export:getWeaponDefaultLabel")
    if not hash then return "Unknown" end
    for name, data in pairs(Config.Weapons) do
        if GetHashKey(name) == hash then
            return data.Label
        end
    end
    return "Unknown"
end)

exports('getWeaponName', function(hash)
    --print("export:getWeaponName")
    if not hash then return nil end
    for name, data in pairs(Config.Weapons) do
        if GetHashKey(name) == hash then
            return name
        end
    end
    return nil
end)

exports('getWeaponsDefaultData', function(request)
    --print("export:getWeaponsDefaultData")
    -- This seems to request the whole table or specific part. 
    -- Returning Config.Weapons seems safe enough for compat.
    return Config.Weapons
end)

exports('getWeaponAmmoTypes', function(group)
    --print("export:getWeaponAmmoTypes")
    if not group then return nil end
    return Config.AmmoTypes[group]
end)

exports('getAmmoLabel', function(ammo)
    --print("export:getAmmoLabel")
    -- Not explicitly in Config, but we can try to guess or return name
    return ammo 
end)

exports('getInventoryItem', function(name)
    --print("export:getInventoryItem")
    return exports["v-inventory"]:getInventoryItem(name)
end)

exports('getInventoryItems', function()
    --print("export:getInventoryItems")
    return exports["v-inventory"]:getInventoryItems()
end)

exports("getServerItem", function(data)
    --print("export:getServerItem")
    -- This was used to get item def from server async in original? 
    -- Leaving nil as its usage is rare/complex to bridge without context
    return nil
end)

exports("useWeapon", function(item) 
    --print("export:useWeapon")
    return exports["v-inventory"]:EquipWeapon(item)
end)

exports("useItem", function(item) 
    --print("export:useItem")
    TriggerServerEvent("v-inventory:server:UseItem", {item = item})
end)
