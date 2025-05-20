-- File: lua/helix/plugins/project_paragon_hud_system/cl_plugin.lua

local PLUGIN = PLUGIN

if CLIENT then
    -- =====================================================================================
    -- EXISTING SCP HUD ELEMENTS CODE (Crosshair, Blink Meter, Sprint, Armor, Ammo, etc.)
    -- ... (all your existing SCP HUD code from the previous version goes here, unchanged) ...
    -- =====================================================================================
    surface.CreateFont("ParagonAmmoFont", {
        font = "DS-Digital",
        size = 18,
        weight = 500,
        antialias = true
    })

    local totalTicks = 20
    local tickWidth, tickHeight = 8, 14
    local tickSpacing = 0 -- For SCP HUD meters
    local iconSize = 30 -- For SCP HUD icons

    local ammoTickWidth, ammoTickHeight = 3, 14
    local ammoIconSize = 30 -- For SCP HUD ammo icon
    local ammoTicksMax = 45

    local blinkIcon      = Material("projectparagon/gfx/BlinkIcon.png", "smooth")
    local sprintIcon     = Material("projectparagon/gfx/sprinticon.png", "smooth")
    local armorIcon      = Material("projectparagon/gfx/kevlarIcon.png", "smooth")
    local armorExtraIcon = Material("projectparagon/gfx/ExtraKevlarMeter.png", "smooth")
    local bulletIcon     = Material("projectparagon/gfx/bulleticon.png", "smooth")
    local aimIcon        = Material("projectparagon/gfx/AimCross.png", "smooth")
    local ammoTickIcon   = Material("projectparagon/gfx/P90_BulletMeter.png", "smooth")
    local tickIcon       = Material("projectparagon/gfx/BlinkMeter.png", "smooth") -- Used by Blink and Armor
    local sprintTickIcon = Material("projectparagon/gfx/StaminaMeter.png", "smooth")
    local crouchIcon     = Material("projectparagon/gfx/sneakicon.png", "smooth")

    local meterY = ScrH() - 60

    local function IsBlinkSystemForcingPlayer()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return false end
        for _, npc in ipairs(ents.FindByClass("npc_cpt_scp_173")) do
            if IsValid(npc) and npc:Health() > 0 then
                if npc:GetPos():DistToSqr(ply:GetPos()) < 500000 then 
                    local trace = util.TraceLine({ start = npc:EyePos(), endpos = ply:EyePos(), filter = {npc, ply}, mask = MASK_VISIBLE_AND_NPCS })
                    if not trace.Hit then return true end
                end
            end
        end
        return false
    end

    hook.Add("HUDPaint", "ParagonHUD_CustomCrosshair", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.GetPrimaryAmmoType or wep:Clip1() == -1 then return end
        local crosshairSize = 32
        local x, y = ScrW() / 2 - crosshairSize / 2, ScrH() / 2 - crosshairSize / 2
        surface.SetMaterial(aimIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, crosshairSize, crosshairSize)
    end)

    hook.Add("HUDPaint", "ParagonHUD_BlinkMeter", function()
        if not IsBlinkSystemForcingPlayer() then return end
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
            local xPos = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(tickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(xPos, barY, tickWidth, tickHeight)
        end
    end)

    hook.Add("HUDPaint", "ParagonHUD_SprintMeter", function() 
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
            local xPos = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(sprintTickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(xPos, barY, tickWidth, tickHeight)
        end
    end)

    hook.Add("HUDPaint", "ParagonHUD_CrouchIndicator", function() 
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        if not ply:Crouching() then return end
        local crouchIconDisplaySize = 40 
        local padding = 90
        local x = ScrW() - crouchIconDisplaySize - padding
        local y = ScrH() - crouchIconDisplaySize - 150
        surface.SetMaterial(crouchIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, crouchIconDisplaySize, crouchIconDisplaySize)
    end)

    hook.Add("HUDPaint", "ParagonHUD_ArmorMeter", function() 
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
            local xPos = barX + (i - 1) * (tickWidth + tickSpacing)
            surface.SetMaterial(tickIcon) 
            surface.SetDrawColor(220, 220, 220, 255)
            surface.DrawTexturedRect(xPos, barY, tickWidth, tickHeight)
        end
        if armor > 100 then
            local overflow = math.Clamp(math.Round((armor - 100) / 100 * totalTicks), 0, totalTicks)
            for i = 1, overflow do
                local xPos = barX + (i - 1) * (tickWidth + tickSpacing)
                surface.SetMaterial(armorExtraIcon) 
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(xPos, barY, tickWidth, tickHeight)
            end
        end
    end)

    hook.Add("HUDPaint", "ParagonHUD_AmmoCounter", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.Clip1 or not wep.GetPrimaryAmmoType or wep:Clip1() < 0 then return end
        local clip = wep:Clip1()
        local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        local maxBulletsInBar = math.Clamp(clip, 0, ammoTicksMax) 
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
        for i = 1, maxBulletsInBar do
            local xPos = barX + (i - 1) * ammoTickWidth
            surface.SetMaterial(ammoTickIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(xPos, barY, ammoTickWidth, ammoTickHeight)
        end
        draw.SimpleText("/" .. reserve, "ParagonAmmoFont", barX + totalBarWidth + 10, barY + (ammoTickHeight / 2), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    -- =====================================================================================
    -- CLIENT-SIDE LOGIC FOR HAND ICON OVERLAY (Unchanged)
    -- ... (all your existing Hand Icon Overlay code goes here, unchanged) ...
    -- =====================================================================================
    local overlayButtonPositions = {} 
    net.Receive("ParagonOverlay_FuncButtons", function(len) 
        local n = net.ReadUInt(16)
        overlayButtonPositions = {} 
        for i = 1, n do
            overlayButtonPositions[#overlayButtonPositions + 1] = net.ReadVector()
        end
    end)

    local matOverlayItem   = ix.util.GetMaterial(PLUGIN.overlayTextureItem)
    local matOverlayButton = ix.util.GetMaterial(PLUGIN.overlayTextureButton)

    hook.Add("HUDPaint", "ParagonOverlay_DrawHandIcon", function() 
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        local eyePos = ply:EyePos()
        local overlayDetectionRadius = PLUGIN.overlayRadius or 0 
        local radiusSq = overlayDetectionRadius * overlayDetectionRadius
        local bestDistSq    = radiusSq 
        local bestDrawPos  = nil
        local bestMaterial = nil
        for _, pos in ipairs(overlayButtonPositions) do
            local distSq = eyePos:DistToSqr(pos) 
            if distSq < bestDistSq then
                bestDistSq    = distSq
                bestDrawPos  = pos
                bestMaterial = matOverlayButton
            end
        end
        for _, ent in ipairs(ents.FindInSphere(eyePos, overlayDetectionRadius)) do
            if not IsValid(ent) then continue end
            local entClass = ent:GetClass() 
            local entModel = (ent:GetModel() or ""):lower() 
            local isWhitelistedClass = PLUGIN.overlayWhitelistedEntities[entClass]
            local isWhitelistedModel = PLUGIN.overlayWhitelistedModels[entModel]
            local isItem = (entClass == "ix_item") 
            if isWhitelistedClass or isWhitelistedModel then
                local modelBoundsMin, modelBoundsMax = ent:GetRenderBounds()
                local worldMin  = ent:LocalToWorld(modelBoundsMin)
                local worldMax  = ent:LocalToWorld(modelBoundsMax)
                local centerEnt = (worldMin + worldMax) * 0.5
                local distSq = eyePos:DistToSqr(centerEnt)
                if distSq < bestDistSq then
                    bestDistSq    = distSq
                    bestDrawPos  = centerEnt
                    if isItem then
                        bestMaterial = matOverlayItem
                    else
                        bestMaterial = matOverlayButton 
                    end
                end
            end
        end
        if not bestDrawPos then return end
        local scrPos = bestDrawPos:ToScreen() 
        if scrPos.visible then 
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(bestMaterial)
            surface.DrawTexturedRect(
                scrPos.x - PLUGIN.overlayIconSize / 2, 
                scrPos.y - PLUGIN.overlayIconSize / 2,
                PLUGIN.overlayIconSize,
                PLUGIN.overlayIconSize
            )
        end
    end)

    -- =====================================================================================
    -- INTEGRATED CUSTOM CURSOR CODE
    -- =====================================================================================
    -- Define the material for the custom cursor.
    -- To make this configurable via sh_plugin.lua later, you could do:
    -- local IX_CURSOR_MATERIAL = Material(PLUGIN.customCursorMaterialPath or "projectparagon/gfx/cursor.PNG")
    -- For now, direct integration as per original plugin:
    local IX_CUSTOM_CURSOR_MATERIAL = Material("projectparagon/gfx/cursor.PNG") -- Renamed to avoid global conflicts

    -- Draw the new cursor function (namespaced to avoid conflicts if 'draw.CustCursor' was too generic)
    function PLUGIN:DrawCustomVGUICursor(material)
        local pos_x, pos_y = input.GetCursorPos()

        if (vgui.CursorVisible()) then
            surface.SetDrawColor(color_white) -- color_white is a GMod global
            surface.SetMaterial(material)
            -- Using PLUGIN.customCursorWidth and PLUGIN.customCursorHeight if you want them configurable
            -- For now, using the original ScreenScale values.
            -- Consider defining these sizes in sh_plugin.lua if you want them easily changeable.
            local cursorWidth = ScreenScale(PLUGIN.customCursorWidth or 5)
            local cursorHeight = ScreenScale(PLUGIN.customCursorHeight or 9)
            surface.DrawTexturedRect(pos_x, pos_y, cursorWidth, cursorHeight)
        end
    end

    -- Post draw cursor hook
    -- Using a unique name for the hook function within the PLUGIN table
    function PLUGIN:PostRenderVGUICustomCursor()
        PLUGIN:DrawCustomVGUICursor(IX_CUSTOM_CURSOR_MATERIAL)
    end
    hook.Add("PostRenderVGUI", "ParagonHUD_PostRenderVGUICustomCursor", function()
        -- Call the PLUGIN's method. This is important if 'self' is used inside DrawCustomVGUICursor,
        -- though in this specific case it isn't. Good practice for plugin structure.
        PLUGIN:PostRenderVGUICustomCursor()
    end)

    -- Delete default windows cursor
    -- Using a unique name for the hook function
    function PLUGIN:ThinkHideDefaultCursor()
        local hover_panel = vgui.GetHoveredPanel()
        if (IsValid(hover_panel)) then
            -- This attempts to hide the OS cursor by setting the panel's cursor to "blank"
            -- The effectiveness can vary, and the ESC menu issue is a known VGUI limitation.
            hover_panel:SetCursor("blank")
        end
    end
    hook.Add("Think", "ParagonHUD_ThinkHideDefaultCursor", function()
        -- Call the PLUGIN's method.
        PLUGIN:ThinkHideDefaultCursor()
    end)

end -- END OF if CLIENT then