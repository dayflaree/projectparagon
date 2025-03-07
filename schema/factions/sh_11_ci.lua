FACTION.name = "Chaos Insurgency"
FACTION.description = ""
FACTION.color = Color(46, 46, 46)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/chaos.mdl",
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
