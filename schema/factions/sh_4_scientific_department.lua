FACTION.name = "Scientific Department"
FACTION.description = ""
FACTION.color = Color(180, 180, 180)

FACTION.isDefault = false

FACTION.models = {
    "models/player/humans/pyri_pm/scientist_pm.mdl",
    "models/player/humans/pyri_pm/scientist_02_pm.mdl",
    "models/player/humans/pyri_pm/scientist_03_pm.mdl",
    "models/player/humans/pyri_pm/scientist_female_pm.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_RE_JUNIOR)
end

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_RE_JUNIOR)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
    end
end

FACTION_RESEARCHER = FACTION.index
