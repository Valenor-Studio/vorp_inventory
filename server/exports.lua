local VInv = exports["v-inventory"]
local INV = {}

-- Helper to safely call VInv
local function SafeCall(fnName, ...)
    if VInv and VInv[fnName] then
        return VInv[fnName](VInv, ...)
    else
        print("^1[vorp_compat] ERROR: v-inventory export '"..tostring(fnName).."' not found.^7")
        return nil
    end
end

-- Helper alias for respond
local function respond(cb, result, message)
	if message then print(message) end
	if cb then cb(result) end
	return result
end

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
         -- If it's a serial strings, finding slot is hard without extra query
    end
end

INV.createWeapon = function(source, weaponName, ammoaux, compaux, comps, custom_serial, custom_label, custom_desc)
    local meta = {
        ammo = ammoaux or 0,
        components = comps or {},
        serial = custom_serial,
        label = custom_label,
        desc = custom_desc or "",
        description = custom_desc -- V-Inv uses description often
    }
    VInv:AddItem(source, weaponName, 1, meta)
    return true
end

INV.deletegun = function(source, id)
    INV.subWeapon(source, id)
    return true
end

INV.canCarryWeapons = function(source, amount, cb, weaponName)
    local can = VInv:canCarryItem(source, weaponName or "weapon", amount)
    return respond(cb, can)
end

INV.getcomps = function(source, weaponid)
    return {}
end

INV.giveWeapon = function(source, weaponid, target)
    local item = nil
    local items = VInv:GetInventory(source)
    
    if items then
         if type(weaponid) == "number" then
             for _, v in ipairs(items) do
                 if v.slot == weaponid then item = v break end
             end
         else
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

-- Mapped to match VORP Item Structure
local function mapToVorpItem(vItem)
    if not vItem then return nil end
    return {
        id = vItem.slot, -- VORP uses 'id' often as slot or DB ID. Slot is safest for session.
        label = vItem.label or vItem.name,
        name = vItem.name,
        desc = (vItem.metadata and vItem.metadata.description) or "",
        metadata = vItem.metadata or {},
        type = vItem.type or "item",
        count = vItem.amount or 0,
        limit = vItem.limit or 100,
        canUse = true, -- simplified
        group = vItem.group or "item", -- simplified
        weight = vItem.weight or 0.0,
        percentage = 100 -- simplified
    }
end

INV.getUserInventoryItems = function(source, cb)
    local items = VInv:GetInventory(source) or {}
    local vorpItems = {}
    for _, v in ipairs(items) do
        table.insert(vorpItems, mapToVorpItem(v))
    end
    return respond(cb, vorpItems)
end

INV.getUserInventoryWeapons = function(source, cb)
    local items = VInv:GetInventory(source) or {}
    local weapons = {}
    for _, v in ipairs(items) do
         if v.type == "item_weapon" or (v.name and string.find(string.upper(v.name), "WEAPON_")) then
             table.insert(weapons, mapToVorpItem(v))
         end
    end
    return respond(cb, weapons)
end

INV.addBullets = function(source, weaponId, type, qty)
    VInv:addBullets(source, weaponId, type, qty)
end

INV.subBullets = function(source, weaponId, type, qty)
end

INV.getWeaponBullets = function(source, weaponId)
    local items = VInv:GetInventory(source)
    if items then
        for _, v in ipairs(items) do
            if v.slot == weaponId then 
                 return (v.metadata and v.metadata.ammo) or 0
            end
        end
    end
    return 0
end

INV.getWeaponComponents = function(source, weaponId)
    return {}
end

INV.getUserWeapons = function(source)
     local items = VInv:GetInventory(source) or {}
     local weapons = {}
     for _, v in ipairs(items) do
          if v.type == "item_weapon" or (v.name and string.find(string.upper(v.name), "WEAPON_")) then
              table.insert(weapons, mapToVorpItem(v))
          end
     end
     return weapons
end

INV.getUserWeapon = function(source, weaponId)
    local items = VInv:GetInventory(source)
    if items then
         for _, v in ipairs(items) do
             if v.slot == weaponId then 
                 return mapToVorpItem(v)
             end
         end
    end
    return nil
end

INV.removeAllUserAmmo = function(source)
end

-- * ITEMS * --
INV.getItem = function(source, itemName, metadata)
    -- VORP: getItem(source, itemName, metadata) -> returns single item with count
    local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
    return mapToVorpItem(item)
end

INV.getItemByMainId = function(source, mainid) 
    -- mainid usually means slot in some contexts or DB ID. 
    -- If passed as number, treat as slot
    if type(mainid) == "number" then
        local items = VInv:GetInventory(source)
        for _, v in ipairs(items) do
            if v.slot == mainid then return mapToVorpItem(v) end
        end
    end
    return nil
end

INV.addItem = function(source, name, amount, metadata, cb, allow, degradation, percentage)
    local success = VInv:AddItem(source, name, amount, metadata)
    return respond(cb, success)
end

-- subItem(source, name, amount, metadata, cb, allow, percentage)
INV.subItem = function(source, name, amount, metadata, cb, allow, percentage)
    -- V-Inv RemoveItem(source, itemName, amount, type, invId, slot)
    -- If metadata is provided, we must find the item first to get its slot
    if metadata then
         local item = VInv:getItemMatchingMetadata(source, name, metadata)
         if item then
             local success = VInv:RemoveItem(source, name, amount, nil, nil, item.slot)
             return respond(cb, success)
         else
             return respond(cb, false)
         end
    else
         local success = VInv:RemoveItem(source, name, amount)
         return respond(cb, success)
    end
end

INV.setItemMetadata = function(source, itemId, metadata, amount, cb)
    local success = VInv:SetItemMetadata(source, itemId, metadata)
    return respond(cb, success)
end

INV.subItemID = function(source, id, cb, allow, amount)
    -- id is slot
    local success = VInv:RemoveItem(source, nil, amount or 1, nil, nil, id)
    return respond(cb, success)
end

INV.getItemByName = function(source, itemName, cb)
     local items = VInv:GetInventory(source)
     if items then
         for _, v in ipairs(items) do
             if v.name == itemName then 
                 return respond(cb, mapToVorpItem(v))
             end
         end
     end
     return respond(cb, nil)
end

INV.getItemContainingMetadata = function(source, itemName, metadata, cb)
    local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
    return respond(cb, mapToVorpItem(item))
end

INV.getItemMatchingMetadata = function(source, itemName, metadata, cb)
    local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
    return respond(cb, mapToVorpItem(item))
end

-- getItemCount(source, cb, itemName, metadata, percentage)
INV.getItemCount = function(source, cb, itemName, metadata, percentage)
    if not source then return respond(cb, 0) end
    
    if metadata then
        local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
        if item then 
            return respond(cb, item.amount or 0)
        else
            return respond(cb, 0)
        end
    else
        local count = VInv:GetItemCount(source, itemName)
        return respond(cb, count)
    end
end

INV.canCarryItems = function(source, amount, cb)
    -- This function in VORP checks "can carry amount items" - meaning total weight usually?
    -- inventoryApiService.lua:89 -> totalAmount + totalAmountWeapons <= character.invCapacity
    -- VInv doesn't expose generic "can carry X more items check" easily without loop.
    -- Assuming true effectively unless we implement weight check against max.
    -- V-Inv checks per item. 
    return respond(cb, true) 
end

INV.canCarryItem = function(target, itemName, amount, cb)
    local can = VInv:canCarryItem(target, itemName, amount)
    return respond(cb, can)
end

INV.RegisterUsableItem = function(itemName, cb)
    if GetResourceState('vorp_core') == 'started' then
        TriggerEvent("vorpCore:registerUsableItem", itemName, cb)
    end
end

INV.unRegisterUsableItem = function(name)
    -- No-op
end

INV.getUserInventory = function(source, cb)
    local items = VInv:GetInventory(source) or {}
    local vorpItems = {}
    for _, v in ipairs(items) do
        table.insert(vorpItems, mapToVorpItem(v))
    end
    return respond(cb, vorpItems)
end

INV.CloseInv = function(source, invId)
    TriggerClientEvent('v-inventory:client:CloseInventory', source)
end

INV.OpenInv = function(source, invId)
end

INV.isCustomInventoryRegistered = function(id, cb)
    return respond(cb, false)
end

INV.getItemDB = function(name, cb)
    local defs = VInv:GetItemDefinitions()
    local d = defs and defs[name]
    if d then
        local item = {
            item = name,
            label = d.label,
            limit = d.limit or 100,
            can_remove = d.can_remove,
            type = d.type,
            usable = true -- Assume true
        }
        return respond(cb, item)
    end
    return respond(cb, nil)
end

-- Export the API object
exports('vorp_inventoryApi', function()
    return INV
end)

-- Direct exports for individual functions
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
exports("getItemById", INV.getItemByMainId) -- Alias
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
exports("unRegisterUsableItem", INV.unRegisterUsableItem)
exports("getUserInventory", INV.getUserInventory)
exports("CloseInv", INV.CloseInv)
exports("OpenInv", INV.OpenInv)
exports("closeInventory", INV.CloseInv)
