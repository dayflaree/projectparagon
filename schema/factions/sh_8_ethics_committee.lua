FACTION.name = "Ethics Committee"
FACTION.description = ""
FACTION.color = Color(0, 161, 255)

FACTION.isDefault = false

FACTION.models = {
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",
    "models/player/suits/male_01_closed_tie.mdl",

}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(nil)
end

function FACTION:OnTransferred(char)
    char:SetClass(nil)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
    end
end

FACTION_ETHICS = FACTION.index