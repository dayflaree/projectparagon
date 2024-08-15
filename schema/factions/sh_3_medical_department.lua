FACTION.name = "Medical Department"
FACTION.description = ""
FACTION.color = Color(120, 120, 250)

FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/scientist.mdl"
}

function FACTION:OnCharacterCreated(ply, char)

end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    ply:SetHealth(100)
    ply:SetArmor(0)
end

FACTION_MEDICAL = FACTION.index