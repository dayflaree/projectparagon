local PLUGIN = PLUGIN or {}
PLUGIN.name = "Custom Pain Death Sounds"
PLUGIN.author = "Claude"
PLUGIN.description = "Replaces default player pain and death sounds with custom ones in the Helix Framework."

-- Configuration for custom sounds
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
        print("[CustomPainDeathSounds] Plugin initialized with " .. #PLUGIN.painSounds .. " pain sounds and " .. #PLUGIN.deathSounds .. " death sounds")
    end
end

return PLUGIN