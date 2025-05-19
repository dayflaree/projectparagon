local PLUGIN = PLUGIN

PLUGIN.name = "Radio Sounds"
PLUGIN.author = "Day"
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
        
        return false
    end

    function PLUGIN:FinishChat()
        local client = LocalPlayer()
        
        if IsValid(client) then
            -- Send event to server, which will check for faction config
            net.Start("ixRadioEndTyping")
            net.SendToServer()
        end
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

-- Example of faction configuration in your schema.lua or faction file
--[[
FACTION.radioConfig = {
    startVoice = "npc/combine_soldier/vo/on1.wav",
    endVoice = "npc/combine_soldier/vo/off3.wav",
    startTyping = "npc/overwatch/radiovoice/on2.wav",
    endTyping = "buttons/button17.wav"
}
]]