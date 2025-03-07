FACTION.name = "Maintenance Department"
FACTION.description = ""
FACTION.color = Color(216, 218, 93)
FACTION.isDefault = false

FACTION.models = {
    "models/painkiller_76/sf2/classd/classd.mdl",
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
