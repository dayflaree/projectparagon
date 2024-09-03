FACTION.name = "Scientific Department"
FACTION.description = ""
FACTION.color = Color(180, 180, 180)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/scientist.mdl"
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_RE_JUNIOR)
end

FACTION_RESEARCHER = FACTION.index
