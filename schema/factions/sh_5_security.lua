FACTION.name = "Security Department"
FACTION.description = ""
FACTION.color = Color(50, 103, 182)
FACTION.isDefault = false
FACTION.models = {
    "models/projectparagon/guard/guard.mdl",
}

FACTION.radioConfig = {
    startVoice = "ProjectParagon/Player/radio_beep1.mp3",
    endVoice = "ProjectParagon/Player/radio_beep2.mp3",
    startTyping = "ProjectParagon/Player/radio_beep1.mp3",
    endTyping = "ProjectParagon/Player/radio_beep2.mp3"
}

function FACTION:ModifyPlayerStep(client, data)

    local secSounds = {
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step1.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step2.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step3.ogg"
    }
    
    local chosenSound = secSounds[math.random(#secSounds)]
    local volume = data.running and 0.8 or 0.4
    
    data.snd = chosenSound
    data.volume = volume

    return false
end

FACTION_SECURITY = FACTION.index
