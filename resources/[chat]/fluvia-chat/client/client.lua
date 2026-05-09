-- Client fluvia-chat : chat commandes uniquement (T pour ouvrir).

local isOpen = false

-- ── Ouvrir sur la touche T ────────────────────────────────────────────────────
RegisterCommand('fluvia_chat', function()
    if not isOpen then OpenChat() end
end, false)
RegisterKeyMapping('fluvia_chat', 'Ouvrir le chat / commandes', 'keyboard', 'T')

-- Désactive le chat FiveM par défaut
AddEventHandler('chat:addMessage', function()
    -- Intercepté : aucun message chat normal affiché
end)

-- ── Ouvrir ────────────────────────────────────────────────────────────────────
function OpenChat()
    isOpen = true
    SetNuiFocus(true, false)  -- souris libre mais mouvement possible
    SendNUIMessage({
        action   = 'open',
        commands = Config.Commands,
    })
end

-- ── NUI → fermer ─────────────────────────────────────────────────────────────
RegisterNUICallback('close', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- ── NUI → exécuter la commande ───────────────────────────────────────────────
RegisterNUICallback('execute', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)

    local input = data.input or ''
    if input == '' then cb({ ok = true }) return end

    -- Supprimer le slash si présent et exécuter la commande
    if input:sub(1, 1) == '/' then
        input = input:sub(2)
    end
    ExecuteCommand(input)
    cb({ ok = true })
end)
