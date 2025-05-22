FACTION.name = "Security Department"
FACTION.color = Color(199, 199, 199)
FACTION.isDefault = false
FACTION.models = {"models/cpthazama/scp/guard.mdl"}
FACTION.introMusic = "projectparagon/sfx/Music/Intro.ogg"

FACTION.defaultHealth = 100
FACTION.maxHealth = 100
FACTION.defaultArmor = 100
FACTION.maxArmor = 200

FACTION.radioConfig = {
    startVoice = "projectparagon/sfx/Character/MTF/radio_beep1.mp3",
    endVoice = "projectparagon/sfx/Character/MTF/radio_beep2.mp3",
    startTyping = "projectparagon/sfx/Character/MTF/radio_beep1.mp3",
    endTyping = "projectparagon/sfx/Character/MTF/radio_beep2.mp3",
    messageSentSound = "projectparagon/sfx/Character/MTF/radio_beep3.ogg",
    breathingLoop = {
        enabled = false,
    }
}

function FACTION:ModifyPlayerStep(client, data)

    local secSounds = {
        "projectparagon/sfx/Character/MTF/Step1.ogg",
        "projectparagon/sfx/Character/MTF/Step2.ogg",
        "projectparagon/sfx/Character/MTF/Step3.ogg"
    }
    
    local chosenSound = secSounds[math.random(#secSounds)]
    local volume = data.running and 0.8 or 0.4
    
    data.snd = chosenSound
    data.volume = volume

    return false
end

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("JSO. "..char:GetName())
    char:SetRank(RANK_SECURITY_JUNIOR)
end

function FACTION:OnSpawn(client)
    timer.Simple(0.1, function()
        if not IsValid(client) then return end

        client:SetHealth(math.min(self.defaultHealth or 100, self.maxHealth or 100))
        client:SetMaxHealth(self.maxHealth or 100)

        client:SetArmor(math.min(self.defaultArmor or 0, self.maxArmor or 100))
    end)
end

FACTION_SECURITY = FACTION.index
