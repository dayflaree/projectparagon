FACTION.name = "Mobile Task Force"
FACTION.description = ""
FACTION.color = Color(136, 52, 52)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/ntf.mdl",
}

function FACTION:ModifyPlayerStep(client, data)

    local mtfSounds = {
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step1.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step2.ogg",
        "ProjectParagon/GameSounds/scpcb/Character/MTF/Step3.ogg"
    }
    
    local chosenSound = mtfSounds[math.random(#mtfSounds)]
    local volume = data.running and 0.8 or 0.4
    
    data.snd = chosenSound
    data.volume = volume

    return false
end

FACTION_MTF = FACTION.index