local PLUGIN = PLUGIN or {}
PLUGIN.name = "Crouch Sounds"
PLUGIN.author = "Claude"
PLUGIN.description = "Plays a random sound when players crouch."

-- Configuration: List of sound files to play when crouching
PLUGIN.crouchSounds = {
    -- Add your custom crouch sounds here
    "projectparagon/sfx/Character/D9341/crouch0.ogg",
    "projectparagon/sfx/Character/D9341/crouch1.ogg",
    "projectparagon/sfx/Character/D9341/crouch2.ogg",
    "projectparagon/sfx/Character/D9341/crouch3.ogg",
    "projectparagon/sfx/Character/D9341/crouch4.ogg",
    "projectparagon/sfx/Character/D9341/crouch5.ogg",
    "projectparagon/sfx/Character/D9341/crouch6.ogg"
}

-- Configuration options
PLUGIN.soundChance = 100       -- Percentage chance to play a sound (0-100)
PLUGIN.cooldown = 1.5          -- Cooldown in seconds between crouch sounds
PLUGIN.soundVolume = 0.75      -- Volume level (0.0-1.0)
PLUGIN.soundDistance = 400     -- Maximum distance to hear the sound
PLUGIN.enabled = true          -- Master toggle for the plugin

if SERVER then
    -- Table to track player cooldowns
    local playerCooldowns = {}
    
    -- Function to play a random crouch sound
    local function PlayCrouchSound(client)
        if not IsValid(client) or not client:IsPlayer() or not PLUGIN.enabled then return end
        
        -- Check if player is on cooldown
        local steamID = client:SteamID()
        if playerCooldowns[steamID] and playerCooldowns[steamID] > CurTime() then
            return
        end
        
        -- Set cooldown for this player
        playerCooldowns[steamID] = CurTime() + PLUGIN.cooldown
        
        -- Check random chance to play sound
        if math.random(1, 100) > PLUGIN.soundChance then return end
        
        -- Make sure we have sounds to play
        if #PLUGIN.crouchSounds == 0 then
            ErrorNoHalt("[CrouchSounds] No sounds defined in PLUGIN.crouchSounds!\n")
            return
        end
        
        -- Pick a random sound
        local soundToPlay = PLUGIN.crouchSounds[math.random(1, #PLUGIN.crouchSounds)]
        
        -- Play the sound in 3D space with configured parameters
        client:EmitSound(soundToPlay, PLUGIN.soundDistance, 100, PLUGIN.soundVolume)
        
        -- Debug info
        -- print("[CrouchSounds] Played " .. soundToPlay .. " for " .. client:Name())
    end
    
    -- Track player crouch state changes
    function PLUGIN:KeyPress(client, key)
        if key == IN_DUCK then
            PlayCrouchSound(client)
        end
    end
    
    -- Admin command to toggle the plugin
    concommand.Add("ix_togglecrouchsounds", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        PLUGIN.enabled = not PLUGIN.enabled
        player:ChatPrint("Crouch sounds " .. (PLUGIN.enabled and "enabled" or "disabled"))
    end)
    
    -- Admin command to change sound chance
    concommand.Add("ix_crouchsoundschance", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        local chance = tonumber(arguments[1])
        if chance and chance >= 0 and chance <= 100 then
            PLUGIN.soundChance = chance
            player:ChatPrint("Crouch sound chance set to " .. chance .. "%")
        else
            player:ChatPrint("Please specify a valid percentage (0-100)")
        end
    end)
    
    -- Initialize plugin
    function PLUGIN:InitPostEntity()
        print("[CrouchSounds] Plugin initialized with " .. #PLUGIN.crouchSounds .. " sounds")
    end
    
    -- Clean up cooldowns for disconnected players
    function PLUGIN:PlayerDisconnected(player)
        local steamID = player:SteamID()
        if playerCooldowns[steamID] then
            playerCooldowns[steamID] = nil
        end
    end
end

-- Client-side config sync
if CLIENT then
    -- Optional: You could add client-side configuration options here
end

return PLUGIN