FACTION.name = "Site Director"
FACTION.description = ""
FACTION.color = Color(120, 20, 20)

FACTION.isDefault = false

FACTION.models = {
    "models/player/nick/scp/site_director/sd.mdl",
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("Site Director "..char:GetName())
end

function FACTION:OnSpawn(ply)
    local char = ply:GetCharacter()
    char:SetClass(nil)
end

function FACTION:OnTransferred(char)
    char:SetClass(nil)
end

function FACTION:OnSpawn(ply)
    local inventory = ply:GetCharacter():GetInventory()
    local item = inventory:HasItem("longrange")
    local item = inventory:HasItem("key5")

    if not ( item ) then
        inventory:Add("longrange", 1, {["frequency"] = ix.config.Get("foundationFrequency")})
        inventory:Add("key5", 1)
    end
end

FACTION_SITEDIRECTOR = FACTION.index