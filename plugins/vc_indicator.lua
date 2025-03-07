local PLUGIN = PLUGIN or {}
PLUGIN.name = "Voice Chat Indicator"
PLUGIN.author = "Claude"
PLUGIN.description = "Displays voice chat indicators for players, including when typing in chat"

-- Configuration
PLUGIN.config = {
    firstPersonIcon = {
        enabled = true,
        size = 42,
        position = {x = 20, y = 20} -- Offset from bottom right
    },
    thirdPersonText = {
        enabled = true,
        text = "Speaking...", -- Shows for both voice and typing
        offset = Vector(0, 0, 5), -- 10 units above head
        font = "Courier New",
        color = Color(255, 255, 255, 255)
    }
}

if CLIENT then
    -- Create materials and fonts when the plugin initializes
    function PLUGIN:InitPostEntity()
        -- Create microphone icon material
        self.micIcon = Material("90/projectparagon/ui/icons/scpcb/hud_textures/micicon.png")
        
        -- Ensure the font exists
        self.thirdPersonFont = self.config.thirdPersonText.font
        if not ix.fonts or not ix.fonts.Exists(self.thirdPersonFont) then
            surface.CreateFont("VoiceIndicatorFont", {
                font = "Courier New",
                size = 24,
                weight = 800,
                antialias = true,
                shadow = true
            })
            self.thirdPersonFont = "VoiceIndicatorFont"
        end
    end

    -- Track voice and typing states
    PLUGIN.voiceStates = {}
    
    -- Voice chat hooks
    function PLUGIN:PlayerStartVoice(player)
        self.voiceStates[player] = true
    end
    
    function PLUGIN:PlayerEndVoice(player)
        self.voiceStates[player] = nil
    end
    
    -- Chat typing hooks
    function PLUGIN:StartChat()
        local client = LocalPlayer()
        if IsValid(client) then
            self.voiceStates[client] = true -- Treat typing as "speaking"
        end
    end
    
    function PLUGIN:FinishChat()
        local client = LocalPlayer()
        if IsValid(client) then
            self.voiceStates[client] = nil -- Reset when typing ends
        end
    end

    -- Draw first-person icon and third-person text
    function PLUGIN:HUDPaint()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        
        -- Draw first-person mic icon (for both voice and typing)
        if self.config.firstPersonIcon.enabled then
            if not self.micIcon or self.micIcon:IsError() then
                self.micIcon = Material("90/projectparagon/ui/icons/scpcb/hud_textures/micicon.png")
                if self.micIcon:IsError() then
                    if self.voiceStates[client] then
                        local size = self.config.firstPersonIcon.size
                        local screenW, screenH = ScrW(), ScrH()
                        local posX = screenW - size - self.config.firstPersonIcon.position.x
                        local posY = screenH - size - self.config.firstPersonIcon.position.y
                        
                        surface.SetDrawColor(255, 255, 255, 255)
                        draw.NoTexture()
                        surface.DrawCircle(posX + size/2, posY + size/2, size/2)
                    end
                    return
                end
            end
            
            if self.voiceStates[client] then -- Show icon for voice or typing
                local size = self.config.firstPersonIcon.size
                local screenW, screenH = ScrW(), ScrH()
                local posX = screenW - size - self.config.firstPersonIcon.position.x
                local posY = screenH - size - self.config.firstPersonIcon.position.y
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(self.micIcon)
                surface.DrawTexturedRect(posX, posY, size, size)
            end
        end

        -- Draw third-person text for all players (voice or typing)
        if not self.config.thirdPersonText.enabled then return end
        
        for _, player in ipairs(player.GetAll()) do
            if not IsValid(player) or not self.voiceStates[player] then continue end
            
            local offset = self.config.thirdPersonText.offset
            local position = player:GetPos() + Vector(0, 0, player:OBBMaxs().z) + offset
            local screenPos = position:ToScreen()
            
            if screenPos.visible then
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
end

-- Server-side: Network typing state to other players
if SERVER then
    util.AddNetworkString("VoiceChatIndicator_Typing")

    hook.Add("PlayerStartTyping", "VoiceChatIndicator_TypingStart", function(player)
        net.Start("VoiceChatIndicator_Typing")
        net.WriteEntity(player)
        net.WriteBool(true)
        net.Broadcast()
    end)

    hook.Add("PlayerFinishTyping", "VoiceChatIndicator_TypingEnd", function(player)
        net.Start("VoiceChatIndicator_Typing")
        net.WriteEntity(player)
        net.WriteBool(false)
        net.Broadcast()
    end)
end

-- Client-side: Receive typing state from server
if CLIENT then
    net.Receive("VoiceChatIndicator_Typing", function()
        local player = net.ReadEntity()
        local isTyping = net.ReadBool()
        if IsValid(player) then
            PLUGIN.voiceStates[player] = isTyping or nil
        end
    end)
end