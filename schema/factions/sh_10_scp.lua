FACTION.name = "SCP"
FACTION.description = ""
FACTION.color = Color(200, 50, 50)

FACTION.isDefault = false

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("SCP-"..Schema:ZeroNumber(math.random(1, 999), 4))
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(nil)
end

function FACTION:OnTransferred(char)
    char:SetClass(nil)
end

FACTION_SCP = FACTION.index
