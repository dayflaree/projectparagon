-- sh_plugin_radiosounds.lua (or your chosen filename for the plugin)
local PLUGIN = PLUGIN

PLUGIN.name = "Radio Sounds"
PLUGIN.author = "Day" -- Original author, modified by Assistant
PLUGIN.description = "Plays radio sounds when players use voice or text chat for configured factions."

-- Register network messages at the earliest possible point
if SERVER then
    util.AddNetworkString("ixRadioStartTyping")
    util.AddNetworkString("ixRadioEndTyping")
end

-- Player metatable additions for tracking state
local playerMeta = FindMetaTable("Player")

function playerMeta:GetRadioSounds()
    local character = self:GetCharacter()
    
    if character then
        local faction = ix.faction.indices[character:GetFaction()]
        
        if faction and faction.radioConfig then
            return faction.radioConfig
        end
    end
    
    return nil
end

function playerMeta:HasRadioConfig()
    return self:GetRadioSounds() ~= nil
end

function playerMeta:PlayRadioSound(soundType)
    -- Check if the player's faction has radio configuration
    if not self:HasRadioConfig() then
        return
    end
    
    local sounds = self:GetRadioSounds()
    local sound = sounds and sounds[soundType]
    
    if sound and SERVER then
        -- Play sound using EmitSound
        -- Parameters: sound path, volume (0-255), pitch (0-255), sound level (volume multiplier 0.0-1.0)
        -- Using 75 for volume and 100 for pitch is common. Sound level 0.5 makes it somewhat localized.
        self:EmitSound(sound, 75, 100, 0.5)
    end
end

-- Voice chat hooks
function PLUGIN:PlayerStartVoice(client)
    if SERVER and IsValid(client) and client:HasRadioConfig() then
        client:PlayRadioSound("startVoice")
    end
end

function PLUGIN:PlayerEndVoice(client)
    if SERVER and IsValid(client) and client:HasRadioConfig() then
        client:PlayRadioSound("endVoice")
    end
end

-- Chat hooks
if CLIENT then
    function PLUGIN:StartChat()
        local client = LocalPlayer()
        
        if IsValid(client) then
            -- Send event to server, which will check for faction config
            net.Start("ixRadioStartTyping")
            net.SendToServer()
        end
        
        return false -- Return false to not override default chatbox behavior
    end

    function PLUGIN:FinishChat()
        local client = LocalPlayer()
        
        if IsValid(client) then
            -- Send event to server, which will check for faction config
            net.Start("ixRadioEndTyping")
            net.SendToServer()
        end
        -- No return here, or return false if you don't want to affect default behavior.
        -- Typically, FinishChat doesn't need to return anything specific unless overriding.
    end
end

-- Network message handling
if SERVER then
    net.Receive("ixRadioStartTyping", function(len, client)
        if IsValid(client) and client:HasRadioConfig() then
            client:PlayRadioSound("startTyping")
        end
    end)
    
    net.Receive("ixRadioEndTyping", function(len, client)
        if IsValid(client) and client:HasRadioConfig() then
            client:PlayRadioSound("endTyping")
        end
    end)
end

-- Hook for when a player sends a message
function PLUGIN:PlayerSay(client, text, teamOnly)
    if SERVER and IsValid(client) and client:HasRadioConfig() then
        -- Play the messageSentSound after the player has sent their message.
        client:PlayRadioSound("messageSentSound")
    end
    
    -- Not returning anything here, or 'return text' to allow the message to proceed normally.
    -- If you return nil or false, it might suppress the chat message.
    -- Helix's PlayerSay hook typically expects you to return the text if you're not modifying it,
    -- or nil/false to block it. For just playing a sound, no return is usually fine,
    -- or explicitly 'return text' to be safe.
    -- However, for this plugin's purpose, we are not modifying the chat text itself.
end


-- Example of faction configuration in your schema's faction file (e.g., sh_mtf_faction.lua)
-- or directly in the FACTION table when defining a faction.
--[[
FACTION.radioConfig = {
    startVoice = "npc/combine_soldier/vo/on1.wav",         -- Sound when player starts talking via voice
    endVoice = "npc/combine_soldier/vo/off3.wav",           -- Sound when player stops talking via voice
    startTyping = "npc/overwatch/radiovoice/on2.wav",       -- Sound when player starts typing in chat
    endTyping = "buttons/button17.wav",                     -- Sound when player finishes typing (sends message or closes chat)
    messageSentSound = "npc/metropolice/vo/tenfour.wav"     -- Sound when player's message is actually sent
}
]]