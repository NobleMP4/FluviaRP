-- Module noclip : déplacement libre dans la direction de la caméra.
-- Activé/désactivé via ToggleNoclip() appelé depuis client.lua.

local noclipActive = false
local noclipSpeed  = 1.5  -- Vitesse de base (unités/frame)

function ToggleNoclip()
    noclipActive = not noclipActive
    local ped = PlayerPedId()

    if noclipActive then
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
    else
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    end

    return noclipActive
end

function IsNoclipActive()
    return noclipActive
end

-- Thread principal noclip
CreateThread(function()
    while true do
        Wait(0)

        if noclipActive then
            local ped    = PlayerPedId()
            local camRot = GetFinalRenderedCamRot(2)  -- en degrés
            local radZ   = math.rad(camRot.z)
            local radX   = math.rad(camRot.x)

            -- Vitesse dynamique : shift = rapide, ctrl = lent
            local speed = noclipSpeed
            if IsControlPressed(0, 21) then speed = speed * 3.0 end   -- Shift
            if IsControlPressed(0, 36) then speed = speed * 0.3 end   -- Ctrl

            local moveX, moveY, moveZ = 0.0, 0.0, 0.0

            if IsControlPressed(0, 32) then  -- W (avancer)
                moveX = moveX + (-math.sin(radZ) * math.cos(radX)) * speed
                moveY = moveY + (math.cos(radZ)  * math.cos(radX)) * speed
                moveZ = moveZ + math.sin(radX) * speed
            end
            if IsControlPressed(0, 33) then  -- S (reculer)
                moveX = moveX - (-math.sin(radZ) * math.cos(radX)) * speed
                moveY = moveY - (math.cos(radZ)  * math.cos(radX)) * speed
                moveZ = moveZ - math.sin(radX) * speed
            end
            if IsControlPressed(0, 34) then  -- A (gauche)
                moveX = moveX + (-math.cos(radZ)) * speed
                moveY = moveY + (-math.sin(radZ)) * speed
            end
            if IsControlPressed(0, 35) then  -- D (droite)
                moveX = moveX - (-math.cos(radZ)) * speed
                moveY = moveY - (-math.sin(radZ)) * speed
            end
            if IsControlPressed(0, 44) then  -- Q (monter)
                moveZ = moveZ + speed
            end
            if IsControlPressed(0, 38) then  -- Z (descendre)
                moveZ = moveZ - speed
            end

            SetEntityCollision(ped, false, false)
            SetEntityVelocity(ped, moveX, moveY, moveZ)
        end
    end
end)
