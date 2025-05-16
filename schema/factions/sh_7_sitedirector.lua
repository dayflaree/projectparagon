FACTION.name = "Site Director"
FACTION.description = ""
FACTION.color = Color(255, 221, 0)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/scientist.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("Site Director "..char:GetName())
end

FACTION_SITEDIRECTOR = FACTION.index
