FACTION.name = "Chaos Insurgency"
FACTION.description = ""
FACTION.color = Color(20, 100, 20)

FACTION.isDefault = false

FACTION.models = {
    "models/player/xuvon/xuvon_ci_re_base.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetClass(CLASS_CI_CONSCRIPT)
    char:SetName("Conscript "..char:GetName())
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(CLASS_CI_CONSCRIPT)
    ply:SetArmor(250)
end

function FACTION:OnTransferred(char)
    char:SetClass(CLASS_CI_CONSCRIPT)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("chaosInsurgencyFrequency")})
    end
end

FACTION_CI = FACTION.index