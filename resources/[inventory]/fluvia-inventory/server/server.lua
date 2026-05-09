-- Inventaire serveur : gestion DB et exports utilisés par les autres ressources.

local function GetOrCreateInventory(ownerType, ownerId)
    local invId = MySQL.scalar.await(
        'SELECT id FROM inventories WHERE owner_type = ? AND owner_id = ?',
        { ownerType, ownerId }
    )
    if not invId then
        invId = MySQL.insert.await(
            'INSERT INTO inventories (owner_type, owner_id) VALUES (?, ?)',
            { ownerType, ownerId }
        )
    end
    return invId
end

local function GetNextFreeSlot(inventoryId)
    local usedSlots = MySQL.query.await(
        'SELECT slot FROM inventory_items WHERE inventory_id = ?',
        { inventoryId }
    )
    local used = {}
    for _, row in ipairs(usedSlots or {}) do
        used[row.slot] = true
    end
    for i = 1, Config.MaxSlots do
        if not used[i] then return i end
    end
    return nil
end

-- ── Export : AddItem ──────────────────────────────────────────────────────────
-- AddItem(src, itemName, amount, metadata)
-- Retourne true si succès, false sinon
exports('AddItem', function(src, itemName, amount, metadata)
    local p = exports['fluvia-core']:GetPlayer(src)
    if not p or not p.characterId then
        print('[FluviaRP Inventory] AddItem : joueur ou personnage introuvable pour src=' .. tostring(src))
        return false
    end

    -- Vérifier que l'item existe dans la config
    if not Config.Items[itemName] then
        print('[FluviaRP Inventory] AddItem : item inconnu "' .. tostring(itemName) .. '"')
        return false
    end

    local invId = GetOrCreateInventory('character', p.characterId)
    local slot  = GetNextFreeSlot(invId)

    if not slot then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Inventaire plein !')
        return false
    end

    MySQL.insert.await(
        'INSERT INTO inventory_items (inventory_id, slot, item_name, amount, metadata) VALUES (?, ?, ?, ?, ?)',
        { invId, slot, itemName, amount or 1, json.encode(metadata or {}) }
    )

    -- Notifier le client
    TriggerClientEvent('fluvia:inventory:itemAdded', src, {
        itemName = itemName,
        amount   = amount or 1,
        metadata = metadata or {},
        label    = Config.Items[itemName].label,
    })

    return true
end)

-- ── Export : RemoveItem ───────────────────────────────────────────────────────
-- RemoveItem(src, itemName, amount, metadata)  -- metadata optionnel pour cibler par métadonnée
exports('RemoveItem', function(src, itemName, amount, metadata)
    local p = exports['fluvia-core']:GetPlayer(src)
    if not p or not p.characterId then return false end

    local invId = GetOrCreateInventory('character', p.characterId)
    local items = MySQL.query.await(
        'SELECT * FROM inventory_items WHERE inventory_id = ? AND item_name = ?',
        { invId, itemName }
    )

    if not items or #items == 0 then return false end

    for _, item in ipairs(items) do
        local meta = json.decode(item.metadata) or {}

        -- Si metadata fourni, vérifier correspondance (ex: même plaque)
        local matches = true
        if metadata then
            for k, v in pairs(metadata) do
                if meta[k] ~= v then matches = false; break end
            end
        end

        if matches then
            if item.amount <= (amount or 1) then
                MySQL.update.await('DELETE FROM inventory_items WHERE id = ?', { item.id })
            else
                MySQL.update.await(
                    'UPDATE inventory_items SET amount = amount - ? WHERE id = ?',
                    { amount or 1, item.id }
                )
            end
            return true
        end
    end

    return false
end)

-- ── Export : GetInventory ─────────────────────────────────────────────────────
exports('GetInventory', function(src)
    local p = exports['fluvia-core']:GetPlayer(src)
    if not p or not p.characterId then return {} end

    local invId = GetOrCreateInventory('character', p.characterId)
    return MySQL.query.await(
        'SELECT * FROM inventory_items WHERE inventory_id = ?',
        { invId }
    ) or {}
end)

-- ── Export : HasItem ──────────────────────────────────────────────────────────
exports('HasItem', function(src, itemName, metadata)
    local items = exports['fluvia-inventory']:GetInventory(src)
    for _, item in ipairs(items) do
        if item.item_name == itemName then
            if not metadata then return true end
            local meta = json.decode(item.metadata) or {}
            local matches = true
            for k, v in pairs(metadata) do
                if meta[k] ~= v then matches = false; break end
            end
            if matches then return true end
        end
    end
    return false
end)

-- ── Net event : admin donne un item ──────────────────────────────────────────
RegisterNetEvent('fluvia:inventory:adminAddItem', function(targetSrc, itemName, amount, metadata)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'vehicles.keys') then return end
    exports['fluvia-inventory']:AddItem(tonumber(targetSrc), itemName, amount, metadata)
end)
