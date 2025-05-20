ITEM.name = "Ballistic Vest"
ITEM.category = "Clothing"
ITEM.model = "models/mishka/models/vest.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.maxArmor = 60
ITEM.outfitCategory = "Torso"

ITEM.allowedModels = {
    "models/cpthazama/scp/dclass.mdl",
    "models/cpthazama/scp/janitor.mdl",
    "models/cpthazama/scp/doctor/doctor.mdl",
    "models/cpthazama/scp/scientist.mdl",
    "models/painkiller_76/sf2/clerk/clerk.mdl",
    "models/cpthazama/scp/guard.mdl",
    "models/cpthazama/scp/lambda.mdl",
    "models/cpthazama/scp/ntf.mdl",
    "models/cpthazama/scp/nu.mdl",
    "models/cpthazama/scp/sneguard.mdl",
    "models/cpthazama/scp/chaosp90.mdl",
    "models/cpthazama/scp/chaos.mdl",
    "models/cpthazama/scp/guard_old.mdl"
}

local absorbingFactions = {
    [FACTION_MTF] = true,
    [FACTION_SECURITY] = true,
    [FACTION_CI] = true
}

ITEM.functions.Equip = {
    name = "Equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    OnRun = function(item)
        local ply = item.player
        local char = ply and ply:GetCharacter()

        if not IsValid(ply) or not char then return false end

        -- Check if player's faction is in the auto-absorb list
        if absorbingFactions[char:GetFaction()] then
            local armorBoost = item.maxArmor or 20
            ply:SetArmor(ply:Armor() + armorBoost)
            ply:EmitSound("projectparagon/sfx/Interact/PickUpKevlar.ogg")
            return true
        end

        -- Default equip logic
        local items = char:GetInventory():GetItems()
        for _, v in pairs(items) do
            if v.id != item.id and v.outfitCategory == item.outfitCategory and v:GetData("equip") then
                ply:NotifyLocalized(item.equippedNotify or "outfitAlreadyEquipped")
                return false
            end
        end

        item:SetData("equip", true)

        if item.maxArmor then
            ply:SetArmor(item:GetData("armor", item.maxArmor))
        end

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player
        return !IsValid(item.entity) and IsValid(ply) and item:GetData("equip") != true and item:CanEquipOutfit()
    end
}
