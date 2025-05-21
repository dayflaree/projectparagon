FACTION.name = "Mobile Task Force"
FACTION.color = Color(173, 125, 78)
FACTION.isDefault = false
FACTION.models = {
    "models/cpthazama/scp/ntf.mdl",
}

FACTION.radioConfig = {
    startVoice = "projectparagon/sfx/Character/MTF/radio_beep1.mp3",
    endVoice = "projectparagon/sfx/Character/MTF/radio_beep2.mp3",
    startTyping = "projectparagon/sfx/Character/MTF/radio_beep1.mp3",
    endTyping = "projectparagon/sfx/Character/MTF/radio_beep2.mp3",
}

function FACTION:ModifyPlayerStep(client, data)
    local mtfSounds = {
        "projectparagon/sfx/Character/MTF/Step1.ogg",
        "projectparagon/sfx/Character/MTF/Step2.ogg",
        "projectparagon/sfx/Character/MTF/Step3.ogg"
    }

    local chosenSound = mtfSounds[math.random(#mtfSounds)]
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
    char:SetName("JO. "..char:GetName())
    char:SetRank(RANK_MTF_JUNIOR)
end

-- Hook to apply default health and armor when player spawns
function FACTION:OnSpawn(client)
    timer.Simple(0.1, function()
        if not IsValid(client) then return end

        client:SetHealth(math.min(self.defaultHealth or 100, self.maxHealth or 100))
        client:SetMaxHealth(self.maxHealth or 100)

        client:SetArmor(math.min(self.defaultArmor or 0, self.maxArmor or 100))
    end)
end

FACTION_MTF = FACTION.index
