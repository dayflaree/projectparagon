FACTION.name = "Mobile Task Force - Epsilon-11"
FACTION.description = ""
FACTION.color = Color(110, 100, 200)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/ntf.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_E11_RECRUIT)
    char:SetName("Private "..char:GetName())
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(CLASS_E11_RECRUIT)
    ply:SetArmor(250)
end

FACTION_MTF = FACTION.index
