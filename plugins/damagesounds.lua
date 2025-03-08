local PLUGIN = PLUGIN or {}

PLUGIN.name = "Enhanced Player Sound Effects"
PLUGIN.author = "Created with Claude's assistance"
PLUGIN.description = "Combines blood drip sounds based on health thresholds with custom pain and death sounds. Also creates blood decals on ground."

-- Configuration for custom pain and death sounds
PLUGIN.painSounds = {
    -- Add your custom pain sounds here
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage3.ogg",
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage4.ogg",
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage6.ogg",
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage7.ogg",
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage8.ogg",
}

PLUGIN.deathSounds = {
    -- Add your custom death sounds here
    "projectparagon/gamesounds/terrorhunt/character/d9341/damage1.ogg",
}

-- Sound replacement settings
PLUGIN.replaceSounds = true      -- Set to false to completely disable all pain/death sounds
PLUGIN.painChance = 50           -- Percentage chance to play pain sounds (0-100)
PLUGIN.deathChance = 100         -- Percentage chance to play death sounds (0-100)

-- Blood drip and decal configuration
PLUGIN.bloodDripConfig = {
    soundPath = "ProjectParagon/GameSounds/terrorhunt/Character/D9341/BloodDrip", -- Default sound path - can be changed to a custom sound
    soundVariations = 4, -- Number of variations of the sound (drip1.wav, drip2.wav, etc.)
    volume = {
        [75] = 0.4, -- Volume at 75% health or below
        [50] = 0.6, -- Volume at 50% health or below
        [25] = 0.8  -- Volume at 25% health or below
    },
    interval = {
        [75] = 10, -- Interval in seconds at 75% health or below
        [50] = 5,  -- Interval in seconds at 50% health or below
        [25] = 2   -- Interval in seconds at 25% health or below
    },
    enableDecals = true, -- Enable blood decals spawning
    decalType = "Blood", -- Decal type to use (Blood is default in GMod)
    decalSize = {
        [75] = 8,   -- Size multiplier at 75% health
        [50] = 12,  -- Size multiplier at 50% health 
        [25] = 16   -- Size multiplier at 25% health
    }
}

-- SERVER-SIDE CODE
if SERVER then
    -- Save original sounds path before overriding
    local origSoundPaths = {}
    
    -- Hook into PlayerHurt to handle pain sounds
    function PLUGIN:PlayerHurt(client, attacker, health, damage)
        if not IsValid(client) or not client:IsPlayer() then return end
        
        -- Only play sound if damage is significant enough
        if damage < 5 then return end
        
        -- Check if we should play the sound based on chance
        if PLUGIN.replaceSounds and math.random(1, 100) <= PLUGIN.painChance and #PLUGIN.painSounds > 0 then
            -- Select a random pain sound from our list
            local soundToPlay = PLUGIN.painSounds[math.random(1, #PLUGIN.painSounds)]
            
            -- Play the sound from the player's position
            client:EmitSound(soundToPlay)
        end
        
        -- Prevent default pain sound behavior
        return true
    end
    
    -- Hook into DoPlayerDeath to handle death sounds
    function PLUGIN:DoPlayerDeath(client, attacker, dmginfo)
        if not IsValid(client) or not client:IsPlayer() then return end
        
        -- Check if we should play the sound based on chance
        if PLUGIN.replaceSounds and math.random(1, 100) <= PLUGIN.deathChance and #PLUGIN.deathSounds > 0 then
            -- Select a random death sound from our list
            local soundToPlay = PLUGIN.deathSounds[math.random(1, #PLUGIN.deathSounds)]
            
            -- Play the sound from the player's position
            client:EmitSound(soundToPlay)
        end
        
        -- Prevent default death sound behavior
        return true
    end
    
    -- Hook into the EntityEmitSound to catch and block specific sounds
    function PLUGIN:EntityEmitSound(data)
        local entity = data.Entity
        
        -- Check if the entity is a player
        if IsValid(entity) and entity:IsPlayer() then
            local soundName = data.SoundName:lower()
            
            -- Save original sound path for debugging
            if not origSoundPaths[soundName] then
                origSoundPaths[soundName] = true
                print("[CustomSounds] Detected sound: " .. soundName)
            end
            
            -- Block common pain/death sound patterns from default system
            if soundName:find("pain") or 
               soundName:find("death") or 
               soundName:find("die") or 
               soundName:find("hurt") or
               soundName:find("grunt") or
               soundName:find("gasp") then
                
                -- Don't block our custom sounds
                for _, sound in ipairs(PLUGIN.painSounds) do
                    if soundName:find(sound:lower()) then
                        return
                    end
                end
                
                for _, sound in ipairs(PLUGIN.deathSounds) do
                    if soundName:find(sound:lower()) then
                        return
                    end
                end
                
                return false
            end
        end
    end
    
    -- Console commands to toggle sound replacement
    concommand.Add("ix_togglepainsounds", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        PLUGIN.painChance = tonumber(arguments[1] or "50")
        player:ChatPrint("Pain sounds chance set to " .. PLUGIN.painChance .. "%")
    end)
    
    concommand.Add("ix_toggledeathsounds", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        PLUGIN.deathChance = tonumber(arguments[1] or "100")
        player:ChatPrint("Death sounds chance set to " .. PLUGIN.deathChance .. "%")
    end)
    
    -- Console command to toggle blood decals
    concommand.Add("ix_toggleblooddecals", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        PLUGIN.bloodDripConfig.enableDecals = not PLUGIN.bloodDripConfig.enableDecals
        player:ChatPrint("Blood decals " .. (PLUGIN.bloodDripConfig.enableDecals and "enabled" or "disabled"))
    end)
    
    -- PrintTable debug command for admins
    concommand.Add("ix_listsounds", function(player, command, arguments)
        if not IsValid(player) or not player:IsAdmin() then return end
        
        player:ChatPrint("Detected original sound paths:")
        local count = 0
        
        for sound, _ in pairs(origSoundPaths) do
            count = count + 1
            player:ChatPrint(count .. ". " .. sound)
            
            if count >= 20 then
                player:ChatPrint("... and more")
                break
            end
        end
    end)
    
    function PLUGIN:InitPostEntity()
        print("[EnhancedSoundEffects] Plugin initialized with " .. #PLUGIN.painSounds .. " pain sounds and " .. #PLUGIN.deathSounds .. " death sounds")
    end
end

-- CLIENT-SIDE CODE
if CLIENT then
    -- Variables to track blood drip state
    local nextDripTime = 0
    local currentHealthThreshold = nil
    local isPlayingDrips = false
    
    -- Blood decal types available in GMod by default
    local bloodDecals = {
        "Blood", 
        "BloodPool"
    }

    -- Function to create a blood decal below the player
    local function CreateBloodDecal(player, threshold)
        if not PLUGIN.bloodDripConfig.enableDecals then return end
        
        -- Get player position
        local pos = player:GetPos()
        
        -- Trace downward to find the ground
        local trace = {
            start = pos,
            endpos = pos - Vector(0, 0, 100), -- Look 100 units down
            filter = player
        }
        
        local tr = util.TraceLine(trace)
        
        if tr.Hit then
            -- Determine decal size based on health threshold
            local decalSize = PLUGIN.bloodDripConfig.decalSize[threshold] or 8
            
            -- Add a slight randomization to position for realism
            local randomOffset = Vector(
                math.random(-5, 5),
                math.random(-5, 5),
                0
            )
            
            -- Get the configured decal type or use a default
            local decalType = PLUGIN.bloodDripConfig.decalType or "Blood"
            
            -- Create the blood decal
            util.Decal(
                decalType,
                tr.HitPos + randomOffset + tr.HitNormal,
                tr.HitPos + randomOffset - tr.HitNormal
            )
        end
    end

    -- Function to play the drip sound
    local function PlayDripSound()
        if not IsValid(LocalPlayer()) then return end
        
        local config = PLUGIN.bloodDripConfig
        local soundVariation = math.random(1, config.soundVariations)
        local soundFile = config.soundPath .. soundVariation .. ".ogg"
        
        -- Play the sound at the appropriate volume based on health threshold
        surface.PlaySound(soundFile)
        
        -- Create blood decal
        if currentHealthThreshold then
            CreateBloodDecal(LocalPlayer(), currentHealthThreshold)
        end
    end

    -- Main timer function to check health and play sounds
    local function CheckHealthAndPlaySound()
        local player = LocalPlayer()
        local config = PLUGIN.bloodDripConfig
        
        -- Make sure player is valid
        if not IsValid(player) then 
            isPlayingDrips = false
            return 
        end
        
        local maxHealth = player:GetMaxHealth()
        local currentHealth = player:Health()
        local healthPercentage = (currentHealth / maxHealth) * 100
        
        -- Determine the appropriate threshold for the current health
        local threshold = nil
        
        if healthPercentage <= 25 then
            threshold = 25
        elseif healthPercentage <= 50 then
            threshold = 50
        elseif healthPercentage <= 75 then
            threshold = 75
        else
            -- Above 75% health, stop playing sounds
            if isPlayingDrips then
                timer.Remove("ix.BloodDripSounds")
                isPlayingDrips = false
                currentHealthThreshold = nil
            end
            return
        end
        
        -- If threshold changed or we're not playing drips yet, restart the timer
        if threshold ~= currentHealthThreshold or not isPlayingDrips then
            if isPlayingDrips then
                timer.Remove("ix.BloodDripSounds")
            end
            
            currentHealthThreshold = threshold
            isPlayingDrips = true
            
            -- Create a new timer with the appropriate interval
            timer.Create("ix.BloodDripSounds", config.interval[threshold], 0, PlayDripSound)
            
            -- Play a sound immediately to provide feedback
            PlayDripSound()
        end
    end

    -- Hook into the HUDPaint to constantly check player health
    function PLUGIN:HUDPaint()
        if not IsValid(LocalPlayer()) then return end
        
        -- Only check every half second to reduce performance impact
        if CurTime() >= nextDripTime then
            CheckHealthAndPlaySound()
            nextDripTime = CurTime() + 0.5
        end
    end

    -- Handle player spawn to reset the drip system
    function PLUGIN:PlayerSpawn(player)
        if player == LocalPlayer() then
            if isPlayingDrips then
                timer.Remove("ix.BloodDripSounds")
                isPlayingDrips = false
                currentHealthThreshold = nil
            end
            nextDripTime = 0
        end
    end

    -- Handle player death to stop the drip system
    function PLUGIN:PlayerDeath(player)
        if player == LocalPlayer() and isPlayingDrips then
            timer.Remove("ix.BloodDripSounds")
            isPlayingDrips = false
            currentHealthThreshold = nil
        end
    end
end

return PLUGIN