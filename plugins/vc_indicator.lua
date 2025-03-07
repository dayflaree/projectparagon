--[[
    Voice Chat Indicator Plugin for Garry's Mod (Helix Framework)
    
    This plugin shows a microphone icon in the bottom right corner when the local player is using voice chat,
    and displays "Speaking..." text above other players who are using voice chat.
]]--

local PLUGIN = PLUGIN or {}
PLUGIN.name = "Voice Chat Indicator"
PLUGIN.author = "Claude"
PLUGIN.description = "Displays voice chat indicators for players"

-- Configuration
PLUGIN.config = {
    firstPersonIcon = {
        enabled = true,
        size = 42,
        position = {x = 20, y = 20} -- Offset from bottom right
    },
    thirdPersonText = {
        enabled = true,
        text = "Speaking...",
        offset = Vector(0, 0, 15), -- Offset from player's head
        font = "ixMediumFont",
        color = Color(255, 255, 255, 255)
    }
}

if CLIENT then
    -- Create materials and fonts when the plugin initializes
    function PLUGIN:InitPostEntity()
        -- Create microphone icon material
        self.micIcon = Material("90/projectparagon/ui/icons/scpcb/hud_textures/micicon.png")
        
        -- Create or get a font for the speaking text
        if !self.thirdPersonFont then
            self.thirdPersonFont = self.config.thirdPersonText.font
            
            if !font.Exists(self.thirdPersonFont) then
                surface.CreateFont(self.thirdPersonFont, {
                    font = "Courier New",
                    size = 24,
                    weight = 800,
                    antialias = true,
                    shadow = true
                })
            end
        end
    end

    -- Track voice chat state
    PLUGIN.voiceStates = {}
    
    -- Listen for voice chat state changes
    function PLUGIN:PlayerStartVoice(player)
        self.voiceStates[player] = true
    end
    
    function PLUGIN:PlayerEndVoice(player)
        self.voiceStates[player] = false
    end
    
    -- Draw first-person icon for the local player
    function PLUGIN:HUDPaint()
        if !self.config.firstPersonIcon.enabled then return end
        
        local client = LocalPlayer()
        if !IsValid(client) then return end
        
        -- Make sure micIcon exists
        if !self.micIcon then
            self.micIcon = Material("90/projectparagon/ui/icons/scpcb/hud_textures/micicon.png")
            -- If it still doesn't exist, use a fallback
            if !self.micIcon or self.micIcon:IsError() then
                self.micIcon = Material("90/projectparagon/ui/icons/scpcb/hud_textures/micicon.png")
                -- Last resort fallback
                if !self.micIcon or self.micIcon:IsError() then
                    -- Draw a simple circle instead of using a material
                    if self.voiceStates[client] then
                        local size = self.config.firstPersonIcon.size
                        local screenW, screenH = ScrW(), ScrH()
                        local posX = screenW - size - self.config.firstPersonIcon.position.x
                        local posY = screenH - size - self.config.firstPersonIcon.position.y
                        
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.DrawCircle(posX + size/2, posY + size/2, size/2, Color(255, 255, 255, 255))
                        return
                    end
                end
            end
        end
        
        -- Simple visibility check - no fading
        if self.voiceStates[client] then
            -- Draw microphone icon in bottom right
            local size = self.config.firstPersonIcon.size
            local screenW, screenH = ScrW(), ScrH()
            local posX = screenW - size - self.config.firstPersonIcon.position.x
            local posY = screenH - size - self.config.firstPersonIcon.position.y
            
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(self.micIcon)
            surface.DrawTexturedRect(posX, posY, size, size)
        end
    end
    
    -- Draw "Speaking..." text above other players' heads
    function PLUGIN:PostPlayerDraw(player)
        if !self.config.thirdPersonText.enabled then return end
        
        -- Don't show text for the local player (since they see the icon)
        if player == LocalPlayer() then return end
        
        -- Check if player is using voice
        if self.voiceStates[player] then
            local offset = self.config.thirdPersonText.offset
            local position = player:GetPos() + Vector(0, 0, player:OBBMaxs().z) + offset
            
            -- Convert 3D position to 2D screen position
            local screenPos = position:ToScreen()
            
            -- Draw the speaking text
            draw.SimpleTextOutlined(
                self.config.thirdPersonText.text,
                self.thirdPersonFont,
                screenPos.x,
                screenPos.y,
                self.config.thirdPersonText.color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                1,
                Color(0, 0, 0, 220)
            )
        end
    end
end

-- Add the plugin to Helix
ix.plugin.Register(PLUGIN)