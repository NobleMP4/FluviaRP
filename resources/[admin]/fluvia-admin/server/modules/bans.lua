-- Gestion des bans

-- Ban d'un joueur (avec durée optionnelle en minutes, 0 = permanent)
RegisterNetEvent('fluvia:admin:ban', function(targetSrc, reason, duration)
    local src = source
    if not CheckPerm(src, 'players.ban') then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Permission refusée.')
        return
    end

    local targetSrcNum = tonumber(targetSrc)
    if not targetSrcNum or not GetPlayerName(targetSrcNum) then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Joueur introuvable.')
        return
    end

    local targetP = exports['fluvia-core']:GetPlayer(targetSrcNum)
    if not targetP then
        TriggerClientEvent('fluvia:notify', src, 'error', 'Joueur non enregistré.')
        return
    end

    local adminP      = exports['fluvia-core']:GetPlayer(src)
    local bannedBy    = adminP and adminP.identifier or 'unknown'
    local banReason   = reason or 'Aucune raison fournie'
    local expiresAt   = nil

    if duration and tonumber(duration) and tonumber(duration) > 0 then
        -- Calcul de l'expiration en UTC
        local expiresTs = os.time() + tonumber(duration) * 60
        expiresAt = os.date('!%Y-%m-%d %H:%M:%S', expiresTs)
    end

    MySQL.insert.await(
        'INSERT INTO bans (identifier, reason, banned_by, expires_at) VALUES (?, ?, ?, ?)',
        { targetP.identifier, banReason, bannedBy, expiresAt }
    )

    local durationText = expiresAt and ('Durée : ' .. tostring(duration) .. ' minutes') or 'Permanent'
    DropPlayer(targetSrcNum, '[FluviaRP] Vous avez été banni.\nRaison : ' .. banReason .. '\n' .. durationText)

    TriggerClientEvent('fluvia:notify', src, 'success',
        'Joueur banni : ' .. GetPlayerName(targetSrcNum) .. ' (' .. durationText .. ')')
end)

-- Débannissement par identifier
RegisterNetEvent('fluvia:admin:unban', function(identifier)
    local src = source
    if not CheckPerm(src, 'players.ban') then return end

    MySQL.update.await(
        'DELETE FROM bans WHERE identifier = ?',
        { identifier }
    )
    TriggerClientEvent('fluvia:notify', src, 'success', 'Ban supprimé pour : ' .. identifier)
end)
