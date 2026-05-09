-- Bootstrap serveur de fluvia-core.
-- Gère la connexion/déconnexion des joueurs et expose les exports.

-- ── Vérification du ban au moment de la connexion ────────────────────────────
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    deferrals.update('[FluviaRP] Vérification en cours...')

    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then
        identifier = GetPlayerIdentifierByType(src, 'steam')
    end

    if identifier then
        -- Vérifier si banni
        local ban = MySQL.scalar.await(
            [[SELECT id FROM bans
              WHERE identifier = ?
              AND (expires_at IS NULL OR expires_at > NOW())]],
            { identifier }
        )

        if ban then
            local banInfo = MySQL.query.await(
                'SELECT reason, expires_at FROM bans WHERE id = ?',
                { ban }
            )
            local reason  = banInfo and banInfo[1] and banInfo[1].reason or 'Aucune raison'
            local expires = banInfo and banInfo[1] and banInfo[1].expires_at or 'Permanent'
            deferrals.done('[FluviaRP] Vous êtes banni.\nRaison : ' .. reason .. '\nExpiration : ' .. tostring(expires))
            return
        end
    end

    -- Enregistrer le joueur
    local player = Players.Register(src)
    if not player then
        deferrals.done('[FluviaRP] Erreur interne. Contactez un administrateur.')
        return
    end

    deferrals.done()
end)

-- ── Nettoyage à la déconnexion ────────────────────────────────────────────────
AddEventHandler('playerDropped', function(reason)
    local src = source
    Players.Remove(src)
    print('[FluviaRP Core] Joueur ' .. GetPlayerName(src) .. ' déconnecté. Raison : ' .. reason)
end)

-- ── Exports serveur (appelés par les autres ressources) ───────────────────────

exports('GetPlayer', function(src)
    return Players.Get(tonumber(src))
end)

exports('GetAllPlayers', function()
    return Players.GetAll()
end)

exports('GetPlayerByIdentifier', function(identifier)
    return Players.GetByIdentifier(identifier)
end)

exports('HasPermission', function(src, node)
    local player = Players.Get(tonumber(src))
    if not player then return false end
    return player:HasPermission(node)
end)

-- ── Event global : notifier un joueur (utilisé par toutes les ressources) ─────
-- TriggerClientEvent('fluvia:notify', src, type, message)
-- type = 'success' | 'error' | 'info' | 'warning'
