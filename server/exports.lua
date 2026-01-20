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

local function respond(cb, result, message)
	if message then print(message) end
	if cb then cb(result) end
	return result
end

-- * WEAPONS * --
INV.subWeapon = function(source, weaponid, cb)
    return respond(cb, VInv:subWeapon(source, weaponid))
end

INV.createWeapon = function(source, weaponName, ammoaux, compaux, comps, custom_serial, custom_label, custom_desc)
    local meta = {
        ammo = ammoaux or 0,
        components = comps or {},
        serial = custom_serial,
        label = custom_label,
        desc = custom_desc
    }
    
    return VInv:AddItem(source, weaponName, 1, meta)
end

INV.deletegun = function(source, id)
    INV.subWeapon(source, id)
    return true
end

INV.canCarryWeapons = function(source, amount, cb, weaponName)
    local can = VInv:canCarryItem(source, weaponName, amount)
    return respond(cb, can) 
end

INV.getcomps = function(source, weaponid)
    return {}
end

INV.giveWeapon = function(source, weaponid, target, cb)
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
           return respond(cb, VInv:AddItem(target, item.name, 1, item.metadata)) 
        end
    end
    return respond(cb, nil)
end

INV.getUserInventoryItems = function(source, cb)
    local items = VInv:GetInventory(source)
    for k, v in pairs(items) do
        items[k].count = v.amount
    end
    return respond(cb, items)
end

INV.getUserInventoryWeapons = function(source, cb)
    return respond(cb, VInv:getUserInventoryWeapons(source))
end

INV.addBullets = function(source, type, amount, cb)
    return respond(cb, nil)
end

INV.subBullets = function(source, type, amount, cb)
    return respond(cb, nil)
end

INV.getWeaponBullets = function(source, weaponId, cb)
    return respond(cb, VInv:getWeaponBullets(source, weaponId))
end

INV.getWeaponComponents = function(source, weaponId)
    return {}
end

INV.getUserWeapons = function(source, cb)
    return respond(cb, VInv:getUserInventoryWeapons(source))
end

INV.getUserWeapon = function(source, cb, weaponId)
    local items = VInv:GetInventory(source)
    if items then
         for _, v in ipairs(items) do
             if v.slot == weaponId then return respond(cb, v) end
         end
    end
    return respond(cb, nil)
end

INV.removeAllUserAmmo = function(source, cb)
    return respond(cb, nil)
end

-- * ITEMS * --
INV.getItem = function(source, itemName, metadata, cb)
    local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
    item.count = tonumber(item.amount)
    return respond(cb, item)
end

INV.getItemByMainId = function(source, mainid, cb) 
    return respond(cb, nil)
end

INV.addItem = function(source, itemName, qty, metadata, cb)
    return respond(cb, VInv:AddItem(source, itemName, qty, metadata))
end

INV.subItem = function(source, itemName, qty, metadata, cb)
    return respond(cb, VInv:RemoveItem(source, itemName, qty))
end

INV.setItemMetadata = function(source, itemId, metadata, amount, cb)
    return respond(cb, VInv:SetItemMetadata(source, itemId, metadata))
end

INV.subItemID = function(source, id, cb)
    return respond(cb, VInv:RemoveItem(source, nil, 1, nil, nil, id))
end

INV.getItemByName = function(source, itemName, cb)
     local items = VInv:GetInventory(source)
     if items then
         for _, v in ipairs(items) do
             if v.name == itemName then return respond(cb, v) end
         end
     end
     return respond(cb, nil)
end

INV.getItemContainingMetadata = function(source, itemName, metadata, cb)
    return respond(cb, VInv:getItemMatchingMetadata(source, itemName, metadata))
end

INV.getItemMatchingMetadata = function(source, itemName, metadata, cb)
    return respond(cb, VInv:getItemMatchingMetadata(source, itemName, metadata))
end

INV.getItemCount = function(source, cb, itemName, metadata)
    if metadata then
        local count = VInv:getItemMatchingMetadata(source, itemName, metadata)
        return respond(cb, count)
    else
        local count = VInv:getItemCount(source, itemName)
        return respond(cb, count)
    end
end

INV.canCarryItems = function(source, amount)
    return true 
end

INV.canCarryItem = function(source, item, amount, cb)
    local can = VInv:canCarryItem(source, item, amount)
    return respond(cb, can)
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
INV.getItemDB = function(name, cb)
    local defs = VInv:GetItemDefinitions()
    return respond(cb, defs and defs[name])
end

-- Export the API object
exports('vorp_inventoryApi', function()
    return INV
end)

exports('isCustomInventoryRegistered', function(id, cb)
    return exports["v-inventory"]:isCustomInventoryRegistered(id, cb)
end)

exports('getCustomInventoryData', function(id, cb)
    return exports["v-inventory"]:getCustomInventoryData(id, cb)
end)

exports('updateCustomInvData', function(data, cb)
    return exports["v-inventory"]:updateCustomInvData(data, cb)
end)

exports('openPlayerInventory', function(data)
    return exports["v-inventory"]:openPlayerInventory(data)
end)

exports('addItemsToCustomInventory', function(invId, items, charId, cb)
    return exports["v-inventory"]:addItemsToCustomInventory(invId, items, charId, cb)
end)

exports('addWeaponsToCustomInventory', function(invId, weapons, charId, cb)
    return exports["v-inventory"]:addWeaponsToCustomInventory(invId, weapons, charId, cb)
end)

exports('getCustomInventoryItemCount', function(invId, itemName, itemCraftedId, cb)
    return exports["v-inventory"]:getCustomInventoryItemCount(invId, itemName, itemCraftedId, cb)
end)

exports('getCustomInventoryWeaponCount', function(invId, weaponName, cb)
    return exports["v-inventory"]:getCustomInventoryWeaponCount(invId, weaponName, cb)
end)

exports('removeItemFromCustomInventory', function(invId, itemName, amount, itemCraftedId, cb)
    return exports["v-inventory"]:removeItemFromCustomInventory(invId, itemName, amount, itemCraftedId, cb)
end)

exports('getCustomInventoryItems', function(invId, cb)
    return exports["v-inventory"]:getCustomInventoryItems(invId, cb)
end)

exports('getCustomInventoryWeapons', function(invId, cb)
    return exports["v-inventory"]:getCustomInventoryWeapons(invId, cb)
end)

exports('updateCustomInventoryItem', function(invId, item_id, metadata, amount, cb)
    return exports["v-inventory"]:updateCustomInventoryItem(invId, item_id, metadata, amount, cb)
end)

exports('removeCustomInventoryWeaponById', function(invId, weapon_id, cb)
    return exports["v-inventory"]:removeCustomInventoryWeaponById(invId, weapon_id, cb)
end)

exports('removeWeaponFromCustomInventory', function(invId, weaponName, cb)
    return exports["v-inventory"]:removeWeaponFromCustomInventory(invId, weaponName, cb)
end)

exports('deleteCustomInventory', function(invId, cb)
    return exports["v-inventory"]:deleteCustomInventory(invId, cb)
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
exports("getUserInventoryItems", INV.getUserInventoryItems)
exports("getUserInventoryWeapons", INV.getUserInventoryWeapons)
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
exports("subItemById", INV.subItemID)
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
