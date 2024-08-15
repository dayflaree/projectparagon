FACTION.name = "Engineering & Technical Service Department"
FACTION.description = ""
FACTION.color = Color(0, 127, 63)

FACTION.isDefault = false

FACTION.models = {
    "models/player/humans/pyri_pm/custodian_pm.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_MN_JANITOR)
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(CLASS_MN_JANITOR)
    ply:SetHealth(100)
    ply:SetArmor(0)
end

FACTION.weapons = {"cityworker_pliers", "cityworker_wrench", "weapon_extinguisher_infinite"}

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_MN_JANITOR)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
    end
end

FACTION_MAINTENANCE = FACTION.index