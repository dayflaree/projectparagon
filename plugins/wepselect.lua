PLUGIN.name = "Weapon Select"
PLUGIN.author = "Chessnut (Modified)"
PLUGIN.description = "A replacement for the default weapon selection."

if (CLIENT) then
    PLUGIN.index = PLUGIN.index or 1
    PLUGIN.deltaIndex = PLUGIN.deltaIndex or PLUGIN.index
    PLUGIN.visible = PLUGIN.visible or false
    PLUGIN.fadeTime = PLUGIN.fadeTime or 0
    PLUGIN.lastWeapons = PLUGIN.lastWeapons or {}
    
    -- Configuration for the weapon selection UI
    local config = {
        boxSize = 64,         -- Size of weapon boxes
        boxSpacing = 10,      -- Spacing between boxes
        boxBorderSize = 2,    -- Size of the selection border
        maxVisible = 6        -- Maximum number of weapons visible at once
    }
    
    function PLUGIN:LoadFonts(font, genericFont)
        surface.CreateFont("ixWeaponSelectFont", {
            font = font,
            size = ScreenScale(10),
            extended = true,
            weight = 1000
        })
    end

    function PLUGIN:HUDShouldDraw(name)
        if (name == "CHudWeaponSelection") then return false end
    end

    function PLUGIN:HUDPaint()
        if (self.visible) then
            local weapons = LocalPlayer():GetWeapons()
            if (#weapons == 0) then return end
            
            -- Update lastWeapons to track what's been rendered
            self.lastWeapons = {}
            
            if (!weapons[self.index]) then
                self.index = #weapons
            end
            
            -- Set deltaIndex to match index immediately for instant movement
            self.deltaIndex = self.index
            
            -- Calculate positioning
            local startX = ScrW() * 0.9 - config.boxSize
            local startY = ScrH() * 0.5 - (#weapons * (config.boxSize + config.boxSpacing)) / 2
            
            -- Determine which weapons to display if there are too many
            local startIndex = 1
            local endIndex = #weapons
            
            if (#weapons > config.maxVisible) then
                local offset = math.floor(config.maxVisible / 2)
                startIndex = math.max(1, self.index - offset)
                endIndex = math.min(#weapons, startIndex + config.maxVisible - 1)
                
                -- Adjust start index if we're near the end
                if (endIndex - startIndex < config.maxVisible - 1) then
                    startIndex = math.max(1, endIndex - config.maxVisible + 1)
                end
            end
            
            -- Track displayed weapons to prevent duplicates
            local displayedWeapons = {}
            
            -- Draw weapon boxes and icons
            for i = startIndex, endIndex do
                local weapon = weapons[i]
                if (!IsValid(weapon)) then continue end
                
                local weaponClass = weapon:GetClass()
                
                -- Skip this weapon if it's already displayed
                if (displayedWeapons[weaponClass]) then continue end
                displayedWeapons[weaponClass] = true
                
                -- Add to lastWeapons tracking
                table.insert(self.lastWeapons, weaponClass)
                
                local boxX = startX
                local boxY = startY + (#self.lastWeapons - 1) * (config.boxSize + config.boxSpacing)
                
                -- Draw the black box (now fully opaque)
                surface.SetDrawColor(0, 0, 0, 255) -- Changed alpha from 200 to 255 for fully black
                surface.DrawRect(boxX, boxY, config.boxSize, config.boxSize)
                
                -- Draw the selection indicator (red outline) if this is the selected weapon
                if (i == self.index) then
                    surface.SetDrawColor(255, 0, 0, 255)
                    for b = 0, config.boxBorderSize - 1 do
                        surface.DrawOutlinedRect(boxX - b, boxY - b, config.boxSize + b * 2, config.boxSize + b * 2)
                    end
                end
                
                -- Draw the weapon icon
                if (weapon.WepSelectIcon and type(weapon.WepSelectIcon) == "IMaterial") then
                    surface.SetMaterial(weapon.WepSelectIcon)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(boxX + 4, boxY + 4, config.boxSize - 8, config.boxSize - 8)
                else
                    -- Attempt to get icon from the weapon table
                    local iconPath = nil
                    if (weapon.GetWeaponSelectIcon) then
                        iconPath = weapon:GetWeaponSelectIcon()
                    end
                    
                    if (iconPath and type(iconPath) == "string") then
                        local iconMat = Material(iconPath)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(iconMat)
                        surface.DrawTexturedRect(boxX + 4, boxY + 4, config.boxSize - 8, config.boxSize - 8)
                    else
                        -- Draw the weapon class name as fallback
                        local weaponName = weapon:GetClass()
                        if (weapon.GetPrintName) then
                            weaponName = weapon:GetPrintName()
                        end
                        
                        surface.SetFont("ixWeaponSelectFont")
                        local textW, textH = surface.GetTextSize(weaponName)
                        
                        -- Center text in box
                        ix.util.DrawText(
                            weaponName, 
                            boxX + config.boxSize/2, 
                            boxY + config.boxSize/2, 
                            color_white, 
                            TEXT_ALIGN_CENTER, 
                            TEXT_ALIGN_CENTER, 
                            "ixWeaponSelectFont"
                        )
                    end
                end
            end
            
            -- Display instructions if available
            if (self.markup) then
                local infoX = startX - 200
                local infoY = startY
                
                self.markup:Draw(infoX, infoY, 0, 0, 255)
            end
            
            -- Hide UI if time elapsed
            if (self.fadeTime < CurTime()) then
                self.visible = false
            end
        end
    end

    function PLUGIN:OnIndexChanged(weapon)
        self.visible = true
        self.fadeTime = CurTime() + 5
        self.markup = nil

        if (IsValid(weapon)) then
            local instructions = weapon.Instructions
            local text = ""

            if (instructions != nil and instructions:find("%S")) then
                local color = ix.config.Get("color")
                text = text .. string.format(
                    "<font=ixItemBoldFont><color=%d,%d,%d>%s</font></color>\n%s\n",
                    color.r, color.g, color.b, L("Instructions"), instructions
                )
            end

            if (text != "") then
                self.markup = markup.Parse("<font=ixItemDescFont>"..text, 190)
            end

            local source, pitch = hook.Run("WeaponCycleSound")
            LocalPlayer():EmitSound(source or "common/talk.wav", 50, pitch or 180)
        end
    end

    function PLUGIN:PlayerBindPress(client, bind, pressed)
        bind = bind:lower()

        if (!pressed or !bind:find("invprev") and !bind:find("invnext")
        and !bind:find("slot") and !bind:find("attack")) then return end

        local currentWeapon = client:GetActiveWeapon()
        local bValid = IsValid(currentWeapon)
        local bTool

        if (client:InVehicle() or (bValid and currentWeapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK))) then return end

        if (bValid and currentWeapon:GetClass() == "gmod_tool") then
            local tool = client:GetTool()
            bTool = tool and (tool.Scroll != nil)
        end

        local weapons = client:GetWeapons()

        if (bind:find("invprev") and !bTool) then
            local oldIndex = self.index
            self.index = math.min(self.index + 1, #weapons)

            if (!self.visible or oldIndex != self.index) then
                self:OnIndexChanged(weapons[self.index])
            end

            return true
        elseif (bind:find("invnext") and !bTool) then
            local oldIndex = self.index
            self.index = math.max(self.index - 1, 1)

            if (!self.visible or oldIndex != self.index) then
                self:OnIndexChanged(weapons[self.index])
            end

            return true
        elseif (bind:find("slot")) then
            self.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #weapons)
            self:OnIndexChanged(weapons[self.index])

            return true
        elseif (bind:find("attack") and self.visible) then
            local weapon = weapons[self.index]

            if (IsValid(weapon)) then
                LocalPlayer():EmitSound(hook.Run("WeaponSelectSound", weapon) or "HL2Player.Use")

                input.SelectWeapon(weapon)
                self.visible = false
            end

            return true
        end
    end

    function PLUGIN:Think()
        local client = LocalPlayer()
        if (!IsValid(client) or !client:Alive()) then
            self.visible = false
        end
    end

    function PLUGIN:ScoreboardShow()
        self.visible = false
    end

    function PLUGIN:ShouldPopulateEntityInfo(entity)
        if (self.visible) then return false end
    end
end