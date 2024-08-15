FACTION.name = "Security Department - Security Response"
FACTION.description = ""
FACTION.color = Color(190, 220, 255)

FACTION.isDefault = false

FACTION.models = {
    "models/player/elan/scpunity/guard/guard_new_texture.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_SS_CADET)
    char:SetName("Cadet "..char:GetName())
end

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_SS_CADET)
    
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
	end
end

FACTION_SECURITYRESPONSE = FACTION.index