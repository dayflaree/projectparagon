-- gamemodes/projectparagon/plugins/damagesounds.lua
local PLUGIN = PLUGIN or {}

PLUGIN.name        = "Enhanced Player Sound Effects"
PLUGIN.author      = "Day"
PLUGIN.description = "Combines blood drip sounds based on health thresholds with custom pain and death sounds. Also creates blood decals on the ground."

-- Configuration for custom pain and death sounds
PLUGIN.painSounds = {
    "projectparagon/sfx/Character/D9341/Damage3.ogg",
    "projectparagon/sfx/Character/D9341/Damage4.ogg",
    "projectparagon/sfx/Character/D9341/Damage6.ogg",
    "projectparagon/sfx/Character/D9341/Damage7.ogg",
    "projectparagon/sfx/Character/D9341/Damage8.ogg"
}

PLUGIN.deathSounds = {
    "projectparagon/sfx/Character/D9341/Damage1.ogg"
}

-- Sound replacement settings
PLUGIN.replaceSounds = true
PLUGIN.painChance    = 50
PLUGIN.deathChance   = 100

-- Blood drip and decal configuration
PLUGIN.bloodDripConfig = {
    soundPath       = "projectparagon/sfx/Character/D9341/BloodDrip",
    soundVariations = 4,
    volume = {
        [75] = 0.4,
        [50] = 0.6,
        [25] = 0.8
    },
    interval = {
        [75] = 10,
        [50] = 5,
        [25] = 2
    },
    enableDecals = true,
    decalType    = "Blood",
    decalSize = {
        [75] = 8,
        [50] = 12,
        [25] = 16
    }
}

-- SERVER-SIDE
if SERVER then
    local origSoundPaths = {}

    function PLUGIN:PlayerHurt(client, attacker, health, damage)
        if not client:IsPlayer() or damage < 5 then return end
        if self.replaceSounds and math.random(1, 100) <= self.painChance and #self.painSounds > 0 then
            client:EmitSound(self.painSounds[math.random(#self.painSounds)])
        end
        return true
    end

    function PLUGIN:DoPlayerDeath(client, attacker, dmginfo)
        if not client:IsPlayer() then return end
        if self.replaceSounds and math.random(1, 100) <= self.deathChance and #self.deathSounds > 0 then
            client:EmitSound(self.deathSounds[math.random(#self.deathSounds)])
        end
        return true
    end

    function PLUGIN:EntityEmitSound(data)
        local ent = data.Entity
        if not (IsValid(ent) and ent:IsPlayer()) then return end

        local snd = string.lower(data.SoundName)
        if not origSoundPaths[snd] then
            origSoundPaths[snd] = true
            print("[EnhancedSFX] Detected sound: " .. snd)
        end

        if snd:find("pain") or snd:find("death") or snd:find("hurt") or snd:find("grunt") or snd:find("gasp") then
            for _, s in ipairs(self.painSounds) do
                if snd:find(string.lower(s)) then return end
            end
            for _, s in ipairs(self.deathSounds) do
                if snd:find(string.lower(s)) then return end
            end
            return false
        end
    end

    concommand.Add("ix_togglepainsounds", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        PLUGIN.painChance = tonumber(args[1]) or PLUGIN.painChance
        ply:ChatPrint("Pain chance set to " .. PLUGIN.painChance .. "%")
    end)

    concommand.Add("ix_toggledeathsounds", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        PLUGIN.deathChance = tonumber(args[1]) or PLUGIN.deathChance
        ply:ChatPrint("Death chance set to " .. PLUGIN.deathChance .. "%")
    end)

    concommand.Add("ix_toggleblooddecals", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        PLUGIN.bloodDripConfig.enableDecals = not PLUGIN.bloodDripConfig.enableDecals
        ply:ChatPrint("Blood decals " .. (PLUGIN.bloodDripConfig.enableDecals and "enabled" or "disabled"))
    end)

    concommand.Add("ix_listsounds", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        ply:ChatPrint("Detected original sounds:")
        local count = 1
        for snd in pairs(origSoundPaths) do
            ply:ChatPrint(count .. ". " .. snd)
            if count >= 20 then break end
            count = count + 1
        end
    end)

    function PLUGIN:InitPostEntity()
        print(string.format(
            "[EnhancedSFX] Loaded with %d pain and %d death sounds.",
            #self.painSounds,
            #self.deathSounds
        ))
    end

    return
end  -- <-- closes the SERVER block

-- CLIENT-SIDE
if CLIENT then
    local nextDripTime = 0
    local currentHealthThreshold = nil
    local isPlayingDrips = false

    local function StopDrips()
        if isPlayingDrips then
            timer.Remove("BloodDripSounds")
            isPlayingDrips = false
            currentHealthThreshold = nil
        end
    end

    local function CreateBloodDecal(player, threshold)
        if not PLUGIN.bloodDripConfig.enableDecals then return end

        local pos = player:GetPos()
        local tr = util.TraceLine({
            start  = pos,
            endpos = pos - Vector(0, 0, 100),
            filter = player
        })

        if tr.Hit then
            local size   = PLUGIN.bloodDripConfig.decalSize[threshold] or 8
            local offset = Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0)
            util.Decal(
                PLUGIN.bloodDripConfig.decalType,
                tr.HitPos + offset + tr.HitNormal,
                tr.HitPos + offset - tr.HitNormal
            )
        end
    end

    local function PlayDripSound()
        local ply = LocalPlayer()
        local cfg = PLUGIN.bloodDripConfig
        local var = math.random(1, cfg.soundVariations)
        local snd = cfg.soundPath .. var .. ".ogg"

        surface.PlaySound(snd)
        if currentHealthThreshold then
            CreateBloodDecal(ply, currentHealthThreshold)
        end
    end

    local function CheckHealthAndPlaySound()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:GetCharacter() then
            StopDrips()
            return
        end

        local hpPerc = (ply:Health() / ply:GetMaxHealth()) * 100
        local threshold

        if hpPerc <= 25 then
            threshold = 25
        elseif hpPerc <= 50 then
            threshold = 50
        elseif hpPerc <= 75 then
            threshold = 75
        else
            StopDrips()
            return
        end

        if threshold ~= currentHealthThreshold or not isPlayingDrips then
            StopDrips()
            currentHealthThreshold = threshold
            isPlayingDrips = true
            timer.Create("BloodDripSounds", PLUGIN.bloodDripConfig.interval[threshold], 0, PlayDripSound)
            PlayDripSound()
        end
    end

    function PLUGIN:HUDPaint()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:GetCharacter() then
            StopDrips()
            return
        end

        if CurTime() >= nextDripTime then
            CheckHealthAndPlaySound()
            nextDripTime = CurTime() + 0.5
        end
    end

    function PLUGIN:PlayerSpawn(player)
        if player == LocalPlayer() then
            StopDrips()
            nextDripTime = 0
        end
    end

    function PLUGIN:PlayerDeath(player)
        if player == LocalPlayer() then
            StopDrips()
        end
    end
end

return PLUGIN
