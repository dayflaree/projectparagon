FACTION.name = "Site Director"
FACTION.description = ""
FACTION.color = Color(120, 20, 20)

FACTION.isDefault = false

FACTION.models = {
    "models/player/nick/scp/site_director/sd.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("Site Director "..char:GetName())
end

FACTION_SITEDIRECTOR = FACTION.index
