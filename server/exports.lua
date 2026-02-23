local VInv = exports["v-inventory"]
local INV = {}

-- Store registered custom inventories
local RegisteredInventories = {}

INV.registerInventory = function(idOrData, name, limit, acceptWeapons, shared, ignoreItemStackLimit, whitelistItems, UsePermissions, UseBlackList, whitelistWeapons)
    --print("registerInventory")
    if not idOrData then return end

    local invId, invName, invLimit
    local data = {}

    -- Handle both table and individual parameters
    if type(idOrData) == "table" then
        -- Table format: registerInventory({id = "x", name = "y", limit = 100, ...})
        data = idOrData
        invId = data.id or data.name
        invName = data.name or data.id
        invLimit = data.limit or 100
    else
        -- Individual parameters format: registerInventory(id, name, limit, ...)
        invId = idOrData
        invName = name or idOrData
        invLimit = limit or 100
        data = {
            id = invId,
            name = invName,
            limit = invLimit,
            acceptWeapons = acceptWeapons,
            shared = shared,
            ignoreItemStackLimit = ignoreItemStackLimit,
            whitelistItems = whitelistItems,
            UsePermissions = UsePermissions,
            UseBlackList = UseBlackList,
            whitelistWeapons = whitelistWeapons
        }
    end

    if not invId then return end
    RegisteredInventories[invId] = data
end

INV.removeInventory = function(idOrData)
    --print("removeInventory")
    local invId = idOrData
    if type(idOrData) == "table" then
        invId = idOrData.id or idOrData.name
    end
    if invId and RegisteredInventories[invId] then
        RegisteredInventories[invId] = nil
    end
end

INV.BlackListCustomAny = function(...) --print("BlackListCustomAny") end
INV.AddPermissionMoveToCustom = function(...) --print("AddPermissionMoveToCustom") end
INV.AddPermissionTakeFromCustom = function(...) --print("AddPermissionTakeFromCustom") end
INV.setInventoryItemLimit = function(...) --print("setInventoryItemLimit") end
INV.setInventoryWeaponLimit = function(...) --print("setInventoryWeaponLimit") end
INV.updateCustomInventorySlots = function(...) --print("updateCustomInventorySlots") end

-- Helper to get registered inventory config
local function GetRegisteredInventory(id)
    --print("GetRegisteredInventory")
    return RegisteredInventories[id]
end

local function respond(cb, result, message)
    --print("respond")
	if message then print(message) end
	if cb and type(cb) == "function" then
		cb(result)
	end
	return result
end

-- * WEAPONS * --
INV.subWeapon = function(source, weaponid, cb)
    --print("subWeapon")
    return respond(cb, VInv:subWeapon(source, weaponid))
end

INV.createWeapon = function(source, weaponName, ammoaux, compaux, comps, custom_serial, custom_label, custom_desc)
    --print("createWeapon")
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
    --print("deletegun")
    INV.subWeapon(source, id)
    return true
end

INV.canCarryWeapons = function(source, amount, cb, weaponName)
    --print("canCarryWeapons")
    local can = VInv:canCarryItem(source, weaponName, amount)
    return respond(cb, can) 
end

INV.getcomps = function(source, weaponid)
    --print("getcomps")
    return {}
end

INV.giveWeapon = function(source, weaponid, target, cb)
    --print("giveWeapon")
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
    --print("getUserInventoryItems")
    local items = VInv:GetInventory(source)
    for k, v in pairs(items) do
        items[k].count = v.amount
    end
    return respond(cb, items)
end

INV.getUserInventoryWeapons = function(source, cb)
    --print("getUserInventoryWeapons")
    return respond(cb, VInv:getUserInventoryWeapons(source))
end

INV.addBullets = function(source, type, amount, cb)
    --print("addBullets")
    return respond(cb, nil)
end

INV.subBullets = function(source, type, amount, cb)
    --print("subBullets")
    return respond(cb, nil)
end

INV.getWeaponBullets = function(source, weaponId, cb)
    --print("getWeaponBullets")
    return respond(cb, VInv:getWeaponBullets(source, weaponId))
end

INV.getWeaponComponents = function(source, weaponId)
    --print("getWeaponComponents")
    return {}
end

INV.getUserWeapons = function(source, cb)
    --print("getUserWeapons")
    return respond(cb, VInv:getUserInventoryWeapons(source))
end

INV.getUserWeapon = function(source, cb, weaponId)
    --print("getUserWeapon")
    local items = VInv:GetInventory(source)
    if items then
         for _, v in ipairs(items) do
             if v.slot == weaponId then return respond(cb, v) end
         end
    end
    return respond(cb, nil)
end

INV.removeAllUserAmmo = function(source, cb)
    --print("removeAllUserAmmo")
    return respond(cb, nil)
end

-- * ITEMS * --
INV.getItem = function(source, itemName, metadata, cb)
    --print("getItem")
    local item = VInv:getItemMatchingMetadata(source, itemName, metadata)
    if item then
        item.count = tonumber(item.amount) or 0
    else
        item = { count = 0, amount = 0 }
    end
    return respond(cb, item)
end

INV.getItemByMainId = function(source, mainid, cb) 
    --print("getItemByMainId")
    return respond(cb, nil)
end

INV.addItem = function(source, itemName, qty, metadata, cb)
    --print("addItem")
    return respond(cb, VInv:AddItem(source, itemName, qty, metadata))
end

INV.subItem = function(source, itemName, qty, metadata, cb)
    --print("subItem")
    return respond(cb, VInv:RemoveItem(source, itemName, qty))
end

INV.setItemMetadata = function(source, itemId, metadata, amount, cb)
    --print("setItemMetadata")
    return respond(cb, VInv:SetItemMetadata(source, itemId, metadata))
end

INV.subItemID = function(source, id, cb)
    --print("subItemID")
    return respond(cb, VInv:subItemById(source, id))
end

INV.getItemByName = function(source, itemName, cb)
     --print("getItemByName")
     local items = VInv:GetInventory(source)
     if items then
         for _, v in ipairs(items) do
             if v.name == itemName then
                 v.count = tonumber(v.amount) or 0
                 return respond(cb, v)
             end
         end
     end
     return respond(cb, nil)
end

INV.getItemContainingMetadata = function(source, itemName, metadata, cb)
    --print("getItemContainingMetadata")
    return respond(cb, VInv:getItemMatchingMetadata(source, itemName, metadata))
end

INV.getItemMatchingMetadata = function(source, itemName, metadata, cb)
    --print("getItemMatchingMetadata")
    return respond(cb, VInv:getItemMatchingMetadata(source, itemName, metadata))
end

INV.getItemCount = function(source, itemNameOrCb, metadataOrItemName, cbOrMetadata)
    --print("getItemCount")
    -- Support multiple parameter orders for backwards compatibility:
    -- Old VORP style: (source, cb, itemName, metadata)
    -- v-invextra style: (source, nil, itemName)
    -- New style: (source, itemName, metadata, cb) or (source, itemName, cb) or (source, itemName)

    local actualItemName, actualMetadata, actualCb

    if type(itemNameOrCb) == "function" then
        -- Old style: (source, cb, itemName, metadata)
        actualCb = itemNameOrCb
        actualItemName = metadataOrItemName
        actualMetadata = cbOrMetadata
    elseif itemNameOrCb == nil and metadataOrItemName ~= nil then
        -- Style: (source, nil, itemName) - v-invextra bridge format
        actualItemName = metadataOrItemName
        actualMetadata = nil
        actualCb = cbOrMetadata
    elseif type(metadataOrItemName) == "function" then
        -- Style: (source, itemName, cb)
        actualItemName = itemNameOrCb
        actualCb = metadataOrItemName
        actualMetadata = nil
    elseif metadataOrItemName == nil and cbOrMetadata == nil then
        -- Style: (source, itemName) - simple two parameter call
        actualItemName = itemNameOrCb
        actualMetadata = nil
        actualCb = nil
    else
        -- Style: (source, itemName, metadata, cb)
        actualItemName = itemNameOrCb
        actualMetadata = metadataOrItemName
        actualCb = cbOrMetadata
    end

    local count = 0
    if actualMetadata then
        local item = VInv:getItemMatchingMetadata(source, actualItemName, actualMetadata)
        count = item and (tonumber(item.amount) or 0) or 0
    else
        -- v-inventory uses GetItemCount(source, itemName) format
        count = VInv:GetItemCount(source, actualItemName) or 0
    end
    return respond(actualCb, count)
end

INV.canCarryItems = function(source, amount, cb)
    print("canCarryItems is DEPRECATED, use canCarryItem")
    return respond(cb, true) 
end

INV.canCarryItem = function(source, item, amount, cb)
    print("canCarryItem")
    local can = VInv:canCarryItem(source, item, amount)
    return respond(cb, can)
end

INV.RegisterUsableItem = function(itemName, cb)
    --print("RegisterUsableItem")
    VInv:registerUsableItem(itemName, cb)
end

INV.getUserInventory = function(source)
    --print("getUserInventory")
    local items = VInv:GetInventory(source)
    if items then
        for _, v in ipairs(items) do
            v.count = tonumber(v.amount) or 0
        end
    end
    return items
end

INV.CloseInv = function(source, invId)
    --print("CloseInv")
    TriggerClientEvent('v-inventory:client:CloseInventory', source)
end

INV.OpenInv = function(source, invId)
    --print("OpenInv")
    if not source or not invId then return end

    -- Get registered inventory config if exists
    local regInv = GetRegisteredInventory(invId)
    local label = regInv and regInv.name or invId
    local slots = regInv and regInv.limit or 100

    -- Create container config for v-inventory
    local container = {
        type = "stash",
        id = invId,
        label = label,
        capacity = 100000, -- Weight capacity
        slots = slots,
        stashType = "public"
    }

    -- Trigger v-inventory stash open
    TriggerClientEvent('v-inventory:client:OpenStashInventory', source, container)
    --print("^2[vorp_inventory bridge] Opening inventory '" .. invId .. "' for player " .. source .. "^7")
end

INV.isCustomInventoryRegistered = function(id)
    --print("isCustomInventoryRegistered")
    if RegisteredInventories[id] then return true end
    -- Also check v-inventory's storage
    return exports["v-inventory"]:isCustomInventoryRegistered(id)
end
INV.getItemDB = function(name, cb)
    --print("getItemDB")
    local defs = VInv:GetItemDefinitions()
    return respond(cb, defs and defs[name])
end

INV.deleteWeapon = function(player, weaponid, cb)
    --print(player, weaponid)
    return respond(cb, INV.subWeapon(player, weaponid))
end

AddEventHandler("vorpCore:canCarryItems", INV.canCarryItems)
AddEventHandler("vorpCore:canCarryItem", INV.canCarryItem)

-- Export the API object
exports('vorp_inventoryApi', function()
    --print("export:vorp_inventoryApi")
    return INV
end)

exports('deleteWeapon', function(player, weaponid, cb)
    return INV.deleteWeapon(player, weaponid, cb)
end)

exports('isCustomInventoryRegistered', function(id, cb)
    --print("export:isCustomInventoryRegistered")
    return exports["v-inventory"]:isCustomInventoryRegistered(id, cb)
end)

exports('getCustomInventoryData', function(id, cb)
    --print("export:getCustomInventoryData")
    return exports["v-inventory"]:getCustomInventoryData(id, cb)
end)

exports('updateCustomInvData', function(data, cb)
    --print("export:updateCustomInvData")
    return exports["v-inventory"]:updateCustomInvData(data, cb)
end)

exports('openPlayerInventory', function(data)
    data.targetId = data.source or 0
    --print("export:openPlayerInventory", json.encode(data))
    return exports["v-inventory"]:openPlayerInventory(data)
end)

exports('addItemsToCustomInventory', function(invId, items, charId, cb)
    --print("export:addItemsToCustomInventory")
    return exports["v-inventory"]:addItemsToCustomInventory(invId, items, charId, cb)
end)

exports('addWeaponsToCustomInventory', function(invId, weapons, charId, cb)
    --print("export:addWeaponsToCustomInventory")
    return exports["v-inventory"]:addWeaponsToCustomInventory(invId, weapons, charId, cb)
end)

exports('getCustomInventoryItemCount', function(invId, itemName, itemCraftedId, cb)
    --print("export:getCustomInventoryItemCount")
    return exports["v-inventory"]:getCustomInventoryItemCount(invId, itemName, itemCraftedId, cb)
end)

exports('getCustomInventoryWeaponCount', function(invId, weaponName, cb)
    --print("export:getCustomInventoryWeaponCount")
    return exports["v-inventory"]:getCustomInventoryWeaponCount(invId, weaponName, cb)
end)

exports('removeItemFromCustomInventory', function(invId, itemName, amount, itemCraftedId, cb)
    --print("export:removeItemFromCustomInventory")
    return exports["v-inventory"]:removeItemFromCustomInventory(invId, itemName, amount, itemCraftedId, cb)
end)

exports('getCustomInventoryItems', function(invId, cb)
    --print("export:getCustomInventoryItems")
    return exports["v-inventory"]:getCustomInventoryItems(invId, cb)
end)

exports('getCustomInventoryWeapons', function(invId, cb)
    --print("export:getCustomInventoryWeapons")
    return exports["v-inventory"]:getCustomInventoryWeapons(invId, cb)
end)

exports('updateCustomInventoryItem', function(invId, item_id, metadata, amount, cb)
    --print("export:updateCustomInventoryItem")
    return exports["v-inventory"]:updateCustomInventoryItem(invId, item_id, metadata, amount, cb)
end)

exports('removeCustomInventoryWeaponById', function(invId, weapon_id, cb)
    --print("export:removeCustomInventoryWeaponById")
    return exports["v-inventory"]:removeCustomInventoryWeaponById(invId, weapon_id, cb)
end)

exports('removeWeaponFromCustomInventory', function(invId, weaponName, cb)
    --print("export:removeWeaponFromCustomInventory")
    return exports["v-inventory"]:removeWeaponFromCustomInventory(invId, weaponName, cb)
end)

exports('deleteCustomInventory', function(invId, cb)
    --print("export:deleteCustomInventory")
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
exports("openInventory", INV.OpenInv)
exports("closeInventory", INV.CloseInv)
