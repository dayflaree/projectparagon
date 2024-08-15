FACTION.name = "Event Faction"
FACTION.description = ""
FACTION.color = Color(20, 100, 140)

FACTION.isDefault = false

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(nil)
end

function FACTION:OnTransferred(char)
    char:SetClass(nil)
end

FACTION_EVENT = FACTION.index