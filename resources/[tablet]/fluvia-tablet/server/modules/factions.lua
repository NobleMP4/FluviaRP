-- CRUD des factions, grades, outfits et points de service.

-- ── Récupérer toutes les factions ────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:getFactions', function()
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    local factions = MySQL.query.await(
        [[SELECT f.*,
            COUNT(DISTINCT cf.id) as member_count
          FROM factions f
          LEFT JOIN character_factions cf ON cf.faction_id = f.id
          GROUP BY f.id
          ORDER BY f.id ASC]],
        {}
    )
    TriggerClientEvent('fluvia:tablet:receiveFactions', src, factions or {})
end)

-- ── Récupérer les grades d'une faction ───────────────────────────────────────
RegisterNetEvent('fluvia:tablet:getFactionGrades', function(factionId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    local grades = MySQL.query.await(
        'SELECT * FROM faction_grades WHERE faction_id = ? ORDER BY grade ASC',
        { factionId }
    )
    TriggerClientEvent('fluvia:tablet:receiveFactionGrades', src, grades or {})
end)

-- ── Récupérer les outfits d'une faction ──────────────────────────────────────
RegisterNetEvent('fluvia:tablet:getFactionOutfits', function(factionId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    local outfits = MySQL.query.await(
        'SELECT * FROM faction_outfits WHERE faction_id = ? ORDER BY id ASC',
        { factionId }
    )
    TriggerClientEvent('fluvia:tablet:receiveFactionOutfits', src, outfits or {})
end)

-- ── Récupérer les points de service d'une faction ────────────────────────────
RegisterNetEvent('fluvia:tablet:getFactionServicePoints', function(factionId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    local sps = MySQL.query.await(
        'SELECT * FROM faction_service_points WHERE faction_id = ? ORDER BY id ASC',
        { factionId }
    )
    TriggerClientEvent('fluvia:tablet:receiveFactionServicePoints', src, sps or {})
end)

-- ── Créer une faction ─────────────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:createFaction', function(data)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    if not data or not data.name or not data.label then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Données invalides.')
        return
    end

    if not data.name:match('^[a-zA-Z0-9_]+$') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Nom invalide (alphanumérique uniquement).')
        return
    end

    local factionId = MySQL.insert.await(
        'INSERT INTO factions (name, label, type, blip_sprite, blip_color) VALUES (?, ?, ?, ?, ?)',
        {
            data.name:lower(),
            data.label,
            data.type or 'legal',
            data.blipSprite or 1,
            data.blipColor  or 0,
        }
    )

    if not factionId then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Ce nom de faction existe déjà.')
        return
    end

    -- Créer un grade par défaut (chef)
    MySQL.insert.await(
        'INSERT INTO faction_grades (faction_id, grade, label, is_boss) VALUES (?, 0, ?, 1)',
        { factionId, 'Chef' }
    )

    TriggerClientEvent('fluvia:notify', src, 'success', 'Faction créée : ' .. data.label)
    -- Diffuser la mise à jour des blips
    TriggerClientEvent('fluvia:factions:refreshBlips', -1)
end)

-- ── Mettre à jour une faction ─────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:updateFaction', function(factionId, data)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    MySQL.update.await(
        'UPDATE factions SET label = ?, type = ?, blip_sprite = ?, blip_color = ? WHERE id = ?',
        { data.label, data.type, data.blipSprite or 1, data.blipColor or 0, factionId }
    )
    TriggerClientEvent('fluvia:notify', src, 'success', 'Faction mise à jour.')
    TriggerClientEvent('fluvia:factions:refreshBlips', -1)
end)

-- ── Supprimer une faction ─────────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:deleteFaction', function(factionId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    MySQL.update.await('DELETE FROM factions WHERE id = ?', { factionId })
    TriggerClientEvent('fluvia:notify', src, 'success', 'Faction supprimée.')
    TriggerClientEvent('fluvia:factions:refreshBlips', -1)
end)

-- ── Ajouter un grade à une faction ───────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:addGrade', function(factionId, gradeLabel, isBoss)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    local maxGrade = MySQL.scalar.await(
        'SELECT MAX(grade) FROM faction_grades WHERE faction_id = ?',
        { factionId }
    )
    local nextGrade = (maxGrade or 0) + 1

    MySQL.insert.await(
        'INSERT INTO faction_grades (faction_id, grade, label, is_boss) VALUES (?, ?, ?, ?)',
        { factionId, nextGrade, gradeLabel, isBoss and 1 or 0 }
    )
    TriggerClientEvent('fluvia:notify', src, 'success', 'Grade ajouté.')
end)

-- ── Sauvegarder une tenue (outfit) ───────────────────────────────────────────
-- L'admin capture sa tenue actuelle depuis le client et l'envoie ici
RegisterNetEvent('fluvia:tablet:saveOutfit', function(factionId, gradeId, label, gender, components)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    if not factionId or not label then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Données invalides.')
        return
    end

    MySQL.insert.await(
        'INSERT INTO faction_outfits (faction_id, grade_id, label, gender, components) VALUES (?, ?, ?, ?, ?)',
        { factionId, gradeId, label, gender or 0, json.encode(components or {}) }
    )
    TriggerClientEvent('fluvia:notify', src, 'success', 'Tenue sauvegardée : ' .. label)
end)

-- ── Poser un point de service ────────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:createServicePoint', function(factionId, label, coords)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    if not factionId or not label or not coords then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Données invalides.')
        return
    end

    MySQL.insert.await(
        'INSERT INTO faction_service_points (faction_id, label, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?)',
        { factionId, label, coords.x, coords.y, coords.z, coords.h or 0.0 }
    )

    TriggerClientEvent('fluvia:notify', src, 'success', 'Point de service posé : ' .. label)
    -- Actualiser les blips sur tous les clients
    TriggerClientEvent('fluvia:factions:refreshBlips', -1)
end)

-- ── Supprimer un point de service ────────────────────────────────────────────
RegisterNetEvent('fluvia:tablet:deleteServicePoint', function(spId)
    local src = source
    if not exports['fluvia-core']:HasPermission(src, 'factions.manage') then return end

    MySQL.update.await('DELETE FROM faction_service_points WHERE id = ?', { spId })
    TriggerClientEvent('fluvia:notify', src, 'success', 'Point de service supprimé.')
    TriggerClientEvent('fluvia:factions:refreshBlips', -1)
end)

-- ── Récupérer tous les points de service (pour les blips clients) ─────────────
RegisterNetEvent('fluvia:factions:requestBlips', function()
    local src = source
    local sps = MySQL.query.await(
        [[SELECT sp.*, f.label as faction_label, f.blip_sprite, f.blip_color
          FROM faction_service_points sp
          JOIN factions f ON f.id = sp.faction_id]],
        {}
    )
    TriggerClientEvent('fluvia:factions:receiveBlips', src, sps or {})
end)
