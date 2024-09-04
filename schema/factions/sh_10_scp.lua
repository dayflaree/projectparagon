FACTION.name = "SCP"
FACTION.description = ""
FACTION.color = Color(200, 50, 50)

FACTION.isDefault = true

FACTION.models = {
    "models/scprp/scp131a2.mdl",
    "models/scprp/scp131b2.mdl"
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("SCP-131-"..Schema:ZeroNumber(math.random(1, 99), 2))
end

FACTION_SCP = FACTION.index
