FACTION.name = "Class-D Personnel"
FACTION.description = "An oppressed group of people forced to wear ridiculous orange jumpsuits."
FACTION.color = Color(250, 150, 0)
FACTION.isDefault = true
FACTION.models = {"models/cpthazama/scp/dclass.mdl"}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("D-"..Schema:ZeroNumber(math.random(1, 99999), 4).." "..char:GetName())

end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(nil)
    ply:SetHealth(100)
    ply:SetArmor(0)
    
end

function FACTION:OnTransferred(char)
    char:SetClass(nil)
end

FACTION_CLASSD = FACTION.index