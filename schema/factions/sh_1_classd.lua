FACTION.name = "Class-D Personnel"
FACTION.description = "An oppressed group of people forced to wear ridiculous orange jumpsuits."
FACTION.color = Color(170, 112, 53)
FACTION.isDefault = true
FACTION.models = {"models/cpthazama/scp/dclass.mdl"}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("D-"..Schema:ZeroNumber(math.random(1, 99999), 4).." "..char:GetName())

end

FACTION_CLASSD = FACTION.index
