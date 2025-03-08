FACTION.name = "Chaos Insurgency"
FACTION.description = ""
FACTION.color = Color(46, 46, 46)
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
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step1.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step2.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step3.ogg"
    }
    
    local chosenSound = ciSounds[math.random(#ciSounds)]
    local volume = data.running and 0.8 or 0.4
    
    data.snd = chosenSound
    data.volume = volume

    return false
end

FACTION_CI = FACTION.index
