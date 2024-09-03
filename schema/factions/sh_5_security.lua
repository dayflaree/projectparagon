FACTION.name = "Security Department"
FACTION.description = ""
FACTION.color = Color(190, 220, 255)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/guard.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_SS_CADET)
    char:SetName("Cadet "..char:GetName())
end

FACTION_SECURITYRESPONSE = FACTION.index
