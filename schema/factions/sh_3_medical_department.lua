FACTION.name = "Health & Safety Department"
FACTION.description = ""
FACTION.color = Color(120, 120, 250)

FACTION.isDefault = false

FACTION.models = {
    "models/player/cheddar/medical/director_art.mdl",
    "models/player/cheddar/medical/director_erdim.mdl",
    "models/player/cheddar/medical/director_eric.mdl",
    "models/player/cheddar/medical/director_mike.mdl",
    "models/player/cheddar/medical/director_ted.mdl",
}

FACTION.weapons = {"weapon_medkit"}

function FACTION:OnCharacterCreated(ply, char)

end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(CLASS_SM_INTERN)
    ply:SetSkin(math.random(1, 3), 3)
    ply:SetHealth(100)
    ply:SetArmor(0)
    ply:SetPlayerColor( Vector( 255, 255, 255 ) )
end

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_SM_INTERN)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
    end
end

FACTION_SITEMEDICAL = FACTION.index