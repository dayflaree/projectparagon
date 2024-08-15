FACTION.name = "Mobile Task Force - Epsilon-11"
FACTION.description = ""
FACTION.color = Color(110, 100, 200)

FACTION.isDefault = false

FACTION.models = {
    "models//players/cheddar/e11/epsilon11_pm.mdl",
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

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_E11_RECRUIT)
    
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
    end
end

FACTION_E11 = FACTION.index
