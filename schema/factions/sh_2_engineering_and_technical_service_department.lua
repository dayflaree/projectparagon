FACTION.name = "Engineering & Technical Service Department"
FACTION.description = ""
FACTION.color = Color(0, 127, 63)
FACTION.isDefault = false

FACTION.models = {
    "models/cpthazama/scp/janitor.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetRank(RANK_ETSD_JANITOR)
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    ply:SetHealth(100)
    ply:SetArmor(0)
end

FACTION_MAINTENANCE = FACTION.index