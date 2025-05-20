FACTION.name = "Chaos Insurgency"
FACTION.color = Color(111, 112, 76)
FACTION.isDefault = false
FACTION.models = {
    "models/cpthazama/scp/chaos.mdl",
}

FACTION.radioConfig = {
    startVoice = "ProjectParagon/Player/radio_beep1.mp3",
    endVoice = "ProjectParagon/Player/radio_beep3.mp3",
    startTyping = "ProjectParagon/Player/radio_beep1.mp3",
    endTyping = "ProjectParagon/Player/radio_beep3.mp3"
}

function FACTION:ModifyPlayerStep(client, data)

    local ciSounds = {
        "projectparagon/sfx/Character/MTF/Step1.ogg",
        "projectparagon/sfx/Character/MTF/Step2.ogg",
        "projectparagon/sfx/Character/MTF/Step3.ogg"
    }
    
    local chosenSound = ciSounds[math.random(#ciSounds)]
    local volume = data.running and 0.8 or 0.4
    
    data.snd = chosenSound
    data.volume = volume

    return false
end

FACTION.defaultHealth = 100
FACTION.maxHealth = 100
FACTION.defaultArmor = 100
FACTION.maxArmor = 200

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("CON. "..char:GetName())
    char:SetRank(RANK_CI_CONSCRIPT)
end

function FACTION:OnSpawn(client)
    timer.Simple(0.1, function()
        if not IsValid(client) then return end

        client:SetHealth(math.min(self.defaultHealth or 100, self.maxHealth or 100))
        client:SetMaxHealth(self.maxHealth or 100)

        client:SetArmor(math.min(self.defaultArmor or 0, self.maxArmor or 100))
    end)
end

FACTION_CI = FACTION.index
