local PLUGIN = PLUGIN

if CLIENT then
    surface.CreateFont("ParagonAmmoFont", {
        font = "DS-Digital",
        size = 18,
        weight = 500,
        antialias = true
    })

    local totalTicks = 20
    local tickWidth, tickHeight = 8, 14
    local tickSpacing = 0
    local iconSize = 30

    local ammoTickWidth, ammoTickHeight = 3, 14
    local ammoIconSize = 30
    local ammoTicksMax = 45

    local blinkIcon      = Material("projectparagon/gfx/BlinkIcon.png", "smooth")
    local sprintIcon     = Material("projectparagon/gfx/sprinticon.png", "smooth")
    local armorIcon      = Material("projectparagon/gfx/kevlarIcon.png", "smooth")
    local armorExtraIcon = Material("projectparagon/gfx/ExtraKevlarMeter.png", "smooth")
    local bulletIcon     = Material("projectparagon/gfx/bulleticon.png", "smooth")
    local aimIcon        = Material("projectparagon/gfx/AimCross.png", "smooth")
    local ammoTickIcon   = Material("projectparagon/gfx/P90_BulletMeter.png", "smooth")
    local tickIcon       = Material("projectparagon/gfx/BlinkMeter.png", "smooth")
    local sprintTickIcon = Material("projectparagon/gfx/StaminaMeter.png", "smooth")
    local crouchIcon     = Material("projectparagon/gfx/sneakicon.png", "smooth")

    local meterY = ScrH() - 60

    local function IsBlinkSystemActive_Client()
        for _, ent in ipairs(ents.GetAll()) do
            if ent:IsNPC() and ent:GetClass() == "npc_cpt_scp_173" then
                return true
            end
        end
        return false
    end

    -- CROSSHAIR
    hook.Add("HUDPaint", "ixCustomCrosshair", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.Clip1 or not wep.GetPrimaryAmmoType or wep:Clip1() < 0 then return end

        local size = 32
        local x, y = ScrW() / 2 - size / 2, ScrH() / 2 - size / 2

        surface.SetMaterial(aimIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, size, size)
    end)

    -- BLINK METER
    hook.Add("HUDPaint", "ixBlinkMeterHUD", function()
        if not IsBlinkSystemActive_Client() then return end

        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local blinkTime = ply:GetNWInt("SCP_BlinkTime", CurTime())
        local isBlinking = ply:GetNWBool("SCP_IsBlinking", false)
        local totalDuration = 15

        local timeRemaining = math.Clamp(blinkTime - CurTime(), 0, totalDuration)
        local percent = isBlinking and 0 or math.Clamp(timeRemaining / totalDuration, 0, 1)
        local activeTicks = math.Clamp(math.Round(percent * totalTicks), 0, totalTicks)

        local totalBarWidth = totalTicks * tickWidth
        local framePadding = 3
        local frameHeight = tickHeight + framePadding * 2

        local baseX = 20
        local blinkY = ScrH() - 100

        surface.SetMaterial(blinkIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(baseX, blinkY, iconSize, iconSize)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(baseX - 1, blinkY - 1, iconSize + 2, iconSize + 2)

        local barX = baseX + iconSize + 12
        local barY = blinkY + math.floor((iconSize - tickHeight) / 2)

        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(barX - framePadding, barY - framePadding, totalBarWidth + framePadding * 2, frameHeight)

        for i = 1, activeTicks do
            local x = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(tickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(x, barY, tickWidth, tickHeight)
        end
    end)

    hook.Add("Think", "CPTBase_ManualBlink", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        if not IsBlinkSystemActive_Client() then return end

        if input.IsKeyDown(KEY_B) and not ply.LastBlinkPressed then
            ply.LastBlinkPressed = true

            if not ply:GetNWBool("SCP_IsBlinking", false) then
                ply:SetNWBool("SCP_IsBlinking", true)

                timer.Simple(0.5, function()
                    if IsValid(ply) and ply:Alive() then
                        ply:SetNWBool("SCP_IsBlinking", false)
                        ply:SetNWInt("SCP_BlinkTime", CurTime() + 15)
                    end
                end)
            end
        elseif not input.IsKeyDown(KEY_B) then
            ply.LastBlinkPressed = false
        end
    end)

    -- SPRINT METER
    hook.Add("HUDPaint", "ixSprintMeterHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local stamina = ply:GetLocalVar("stm", 100)
        local activeTicks = math.Clamp(math.Round((stamina / 100) * totalTicks), 0, totalTicks)

        local totalBarWidth = totalTicks * tickWidth
        local baseX = 20
        local framePadding = 3
        local frameHeight = tickHeight + framePadding * 2

        surface.SetMaterial(sprintIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(baseX, meterY, iconSize, iconSize)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(baseX - 1, meterY - 1, iconSize + 2, iconSize + 2)

        local barX = baseX + iconSize + 12
        local barY = meterY + math.floor((iconSize - tickHeight) / 2)

        surface.DrawOutlinedRect(barX - framePadding, barY - framePadding, totalBarWidth + framePadding * 2, frameHeight)

        for i = 1, activeTicks do
            local x = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(sprintTickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(x, barY, tickWidth, tickHeight)
        end
    end)

    -- CROUCH ICON
    hook.Add("HUDPaint", "ixCrouchIndicator", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        if not ply:Crouching() then return end

        local iconSize = 40
        local padding = 30
        local x = ScrW() - iconSize - padding
        local y = ScrH() - iconSize - 150

        surface.SetMaterial(crouchIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, iconSize, iconSize)
    end)

    -- ARMOR METER
    hook.Add("HUDPaint", "ixArmorMeterHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local armor = ply:Armor()
        if armor <= 0 then return end

        local totalBarWidth = totalTicks * tickWidth
        local framePadding = 3
        local frameHeight = tickHeight + framePadding * 2
        local baseX = ScrW() - (totalBarWidth + iconSize + 36)

        surface.SetMaterial(armorIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(baseX, meterY, iconSize, iconSize)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(baseX - 1, meterY - 1, iconSize + 2, iconSize + 2)

        local barX = baseX + iconSize + 12
        local barY = meterY + math.floor((iconSize - tickHeight) / 2)

        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(barX - framePadding, barY - framePadding, totalBarWidth + framePadding * 2, frameHeight)

        local baseTicks = math.Clamp(math.Round(math.min(armor, 100) / 100 * totalTicks), 0, totalTicks)
        for i = 1, baseTicks do
            local x = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(tickIcon)
            surface.SetDrawColor(220, 220, 220, 255)
            surface.DrawTexturedRect(x, barY, tickWidth, tickHeight)
        end

        if armor > 100 then
            local overflow = math.Clamp(math.Round((armor - 100) / 100 * totalTicks), 0, totalTicks)
            for i = 1, overflow do
                local x = barX + (i - 1) * (tickWidth + tickSpacing)
                surface.SetMaterial(armorExtraIcon)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(x, barY, tickWidth, tickHeight)
            end
        end
    end)

    -- AMMO COUNTER
    hook.Add("HUDPaint", "ixAmmoCounterHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.Clip1 or not wep.GetPrimaryAmmoType or wep:Clip1() < 0 then return end

        local clip = wep:Clip1()
        local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())

        local maxBullets = math.Clamp(clip, 0, ammoTicksMax)
        local totalBarWidth = ammoTicksMax * ammoTickWidth

        local baseX = ScrW() - (totalBarWidth + ammoIconSize + 61)
        local baseY = meterY - 40

        surface.SetMaterial(bulletIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(baseX, baseY, ammoIconSize, ammoIconSize)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(baseX - 1, baseY - 1, ammoIconSize + 2, ammoIconSize + 2)

        local barX = baseX + ammoIconSize + 12
        local barY = baseY + math.floor((ammoIconSize - ammoTickHeight) / 2)

        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawOutlinedRect(barX - 3, barY - 3, totalBarWidth + 6, ammoTickHeight + 6)

        for i = 1, maxBullets do
            local x = barX + (i - 1) * ammoTickWidth
            surface.SetMaterial(ammoTickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(x, barY, ammoTickWidth, ammoTickHeight)
        end

        draw.SimpleText("/" .. reserve, "ParagonAmmoFont", barX + totalBarWidth + 10, barY + 6, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)
end
