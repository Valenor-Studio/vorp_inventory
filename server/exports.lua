local VInv = exports["v-inventory"]
local INV = {}

INV.registerInventory = function(...)
     print("^3[v-inventory] Ignored registerInventory (legacy compatibility)^7")
end
INV.removeInventory = function(...) end
INV.BlackListCustomAny = function(...) end
INV.AddPermissionMoveToCustom = function(...) end
INV.AddPermissionTakeFromCustom = function(...) end
INV.setInventoryItemLimit = function(...) end
INV.setInventoryWeaponLimit = function(...) end
INV.updateCustomInventorySlots = function(...) end

-- * WEAPONS * --
INV.subWeapon = function(source, weaponid)
    if type(weaponid) == "number" then
         VInv:RemoveItem(source, nil, 1, nil, nil, weaponid)
    else
         VInv:RemoveItem(source, weaponid, 1)
    end
end

INV.createWeapon = function(source, weaponName, ammoaux, compaux, comps, custom_serial, custom_label, custom_desc)
    local meta = {
        ammo = ammoaux or 0,
        components = comps or {},
        serial = custom_serial,
        label = custom_label,
        desc = custom_desc
    }
    VInv:AddItem(source, weaponName, 1, meta)
    return true
end

INV.deletegun = function(source, id)
    INV.subWeapon(source, id)
    return true
end

INV.canCarryWeapons = function(source, amount, cb, weaponName)
    local can = VInv:CanCarryItem(source, weaponName, amount)
    if cb then cb(can) end
    return can
end

INV.getcomps = function(source, weaponid)
    return {}
end

INV.giveWeapon = function(source, weaponid, target)
    local item = nil
    if type(weaponid) == "number" then
         local items = VInv:GetInventory(source)
         if items then
             for _, v in ipairs(items) do
                 if v.slot == weaponid then item = v break end
             end
         end
    else
         local items = VInv:GetInventory(source)
         if items then
             for _, v in ipairs(items) do
                 if v.name == weaponid then item = v break end
             end
         end
    end

    if item then
        local success = VInv:RemoveItem(source, item.name, 1, nil, nil, item.slot)
        if success then
            VInv:AddItem(target, item.name, 1, item.metadata)
        end
    end
end

INV.addBullets = function(source, weaponId, type, qty)
    VInv:addBullets(source, weaponId, type, qty)
end

INV.subBullets = function(source, weaponId, type, qty)
    VInv:subBullets(source, weaponId, type, qty)
end

INV.getWeaponBullets = function(source, weaponId)
    return VInv:getWeaponBullets(source, weaponId)
end

INV.getWeaponComponents = function(source, weaponId)
    return {}
end

INV.getUserWeapons = function(source)
    return VInv:getUserInventoryWeapons(source)
end

INV.getUserWeapon = function(source, weaponId)
    local items = VInv:GetInventory(source)
    if items then
         for _, v in ipairs(items) do
             if v.slot == weaponId then return v end
         end
    end
    return nil
end

INV.removeAllUserAmmo = function(source) end

-- * ITEMS * --
INV.getItem = function(source, itemName, metadata)
    return VInv:getItemMatchingMetadata(source, itemName, metadata)
end

INV.getItemByMainId = function(source, mainid) 
    return nil
end

INV.addItem = function(source, itemName, qty, metadata)
    return VInv:AddItem(source, itemName, qty, metadata)
end

INV.subItem = function(source, itemName, qty, metadata)
    return VInv:RemoveItem(source, itemName, qty)
end

INV.setItemMetadata = function(source, itemId, metadata, amount)
    return VInv:SetItemMetadata(source, itemId, metadata)
end

INV.subItemID = function(source, id)
    return VInv:RemoveItem(source, nil, 1, nil, nil, id)
end

INV.getItemByName = function(source, itemName)
     local items = VInv:GetInventory(source)
     if items then
         for _, v in ipairs(items) do
             if v.name == itemName then return v end
         end
     end
     return nil
end

INV.getItemContainingMetadata = function(source, itemName, metadata)
    return VInv:getItemMatchingMetadata(source, itemName, metadata)
end

INV.getItemMatchingMetadata = function(source, itemName, metadata)
    return VInv:getItemMatchingMetadata(source, itemName, metadata)
end

INV.getItemCount = function(source, item, metadata)
    return VInv:getItemCount(source, item)
end

INV.canCarryItems = function(source, amount)
    return true 
end

INV.canCarryItem = function(source, item, amount)
    return VInv:canCarryItem(source, item, amount)
end

INV.RegisterUsableItem = function(itemName, cb)
    VInv:registerUsableItem(itemName, cb)
end

INV.getUserInventory = function(source)
    return VInv:GetInventory(source)
end

INV.CloseInv = function(source, invId)
    TriggerClientEvent('v-inventory:client:CloseInventory', source)
end

INV.OpenInv = function(source, invId)
end

INV.isCustomInventoryRegistered = function()
end
INV.getItemDB = function(name)
    local defs = VInv:GetItemDefinitions()
    return defs and defs[name]
end

-- Export the API object
exports('vorp_inventoryApi', function()
    return INV
end)

-- Direct exports for individual functions
-- NOTE: Some of these may override bridge_server.lua exports depending on load order and name collisions.
-- However, since vorp_compat.lua is loaded LAST, these will take precedence if names match.
exports("isCustomInventoryRegistered", INV.isCustomInventoryRegistered)
exports("registerInventory", INV.registerInventory)
exports("removeInventory", INV.removeInventory)
exports("BlackListCustomAny", INV.BlackListCustomAny)
exports("AddPermissionMoveToCustom", INV.AddPermissionMoveToCustom)
exports("AddPermissionTakeFromCustom", INV.AddPermissionTakeFromCustom)
exports("setInventoryItemLimit", INV.setInventoryItemLimit)
exports("setInventoryWeaponLimit", INV.setInventoryWeaponLimit)
exports("updateCustomInventorySlots", INV.updateCustomInventorySlots)
exports("subWeapon", INV.subWeapon)
exports("createWeapon", INV.createWeapon)
exports("deletegun", INV.deletegun)
exports("canCarryWeapons", INV.canCarryWeapons)
exports("getcomps", INV.getcomps)
exports("giveWeapon", INV.giveWeapon)
exports("addBullets", INV.addBullets)
exports("subBullets", INV.subBullets)
exports("getWeaponBullets", INV.getWeaponBullets)
exports("getWeaponComponents", INV.getWeaponComponents)
exports("getUserWeapons", INV.getUserWeapons)
exports("getUserWeapon", INV.getUserWeapon)
exports("removeAllUserAmmo", INV.removeAllUserAmmo)
exports("getItem", INV.getItem)
exports("getItemDB", INV.getItemDB)
exports("getItemByMainId", INV.getItemByMainId)
exports("addItem", INV.addItem)
exports("subItem", INV.subItem)
exports("setItemMetadata", INV.setItemMetadata)
exports("subItemID", INV.subItemID)
exports("getItemByName", INV.getItemByName)
exports("getItemContainingMetadata", INV.getItemContainingMetadata)
exports("getItemMatchingMetadata", INV.getItemMatchingMetadata)
exports("getItemCount", INV.getItemCount)
exports("canCarryItems", INV.canCarryItems)
exports("canCarryItem", INV.canCarryItem)
exports("RegisterUsableItem", INV.RegisterUsableItem)
exports("registerUsableItem", INV.RegisterUsableItem)
exports("getUserInventory", INV.getUserInventory)
exports("CloseInv", INV.CloseInv)
exports("OpenInv", INV.OpenInv)
exports("closeInventory", INV.CloseInv)
