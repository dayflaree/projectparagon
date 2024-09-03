FACTION.name = "05 Council"
FACTION.description = ""
FACTION.color = Color(10, 10, 10)

FACTION.isDefault = false

FACTION.models = {
    "models/player/suits/male_01_closed_coat_tie.mdl",
    "models/player/suits/male_02_closed_coat_tie.mdl",
    "models/player/suits/male_03_closed_coat_tie.mdl",
    "models/player/suits/male_04_closed_coat_tie.mdl",
    "models/player/suits/male_05_closed_coat_tie.mdl",
    "models/player/suits/male_06_closed_coat_tie.mdl",
    "models/player/suits/male_07_closed_coat_tie.mdl",
    "models/player/suits/male_08_closed_coat_tie.mdl",
    "models/player/suits/male_09_closed_coat_tie.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("O5-"..Schema:ZeroNumber(math.random(1, 12), 2).." "..char:GetName())
end

FACTION_O5COUNCIL = FACTION.index
