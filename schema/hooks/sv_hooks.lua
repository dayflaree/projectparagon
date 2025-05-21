function Schema:CanPlayerThrowPunch()
    return false
end

function Schema:PlayerSpray()
    return false
end

function Schema:PlayerSpawnRagdoll(ply)
    return ply:IsAdmin()
end

function Schema:PlayerSpawnSENT(ply)
    return ply:IsAdmin()
end

function Schema:PlayerSpawnSWEP(ply)
    return ply:IsAdmin()
end

function Schema:PlayerSpawnVehicle(ply)
    return ply:IsAdmin()
end

function Schema:GetPlayerDeathSound(client)
    return
end

function Schema:GetPlayerPainSound(client)
    return
end

function Schema:PlayerModelChanged(ply, model)
    if (not IsValid(ply) or ply:IsBot()) then return end
    ply:SetupHands()
end

function Schema:PostPlayerSay(client, chatType, message, anonymous)
    if (chatType == "ic") then
        ix.log.Add(client, "chat", chatType and chatType:utf8upper() or "??", text or message)
    end
end

function Schema:PlayerInteractItem(ply, action, item)
    if (action == "take") then
        if (item.interactSounds and istable(item.interactSounds)) then
            ply:EmitSound(item.interactSounds[math.random(1, #item.interactSounds)])
        end
    end
end

hook.Add("Think", "ClampFactionHealthAndArmor", function()
    for _, ply in ipairs(player.GetAll()) do
        local char = ply:GetCharacter()
        if not char then continue end

        local faction = ix.faction.indices[char:GetFaction()]
        if not faction then continue end

        if faction.maxHealth and ply:Health() > faction.maxHealth then
            ply:SetHealth(faction.maxHealth)
        end

        if faction.maxArmor and ply:Armor() > faction.maxArmor then
            ply:SetArmor(faction.maxArmor)
        end
    end
end)

local RECOGNIZED_ARMOR_ITEM_IDS_LIST = {
    "torso_armor1",
    "torso_armor2",
    "torso_armor3",
}

local ARMOR_ITEM_SET = {}
for _, idString in ipairs(RECOGNIZED_ARMOR_ITEM_IDS_LIST) do
    ARMOR_ITEM_SET[idString] = true
end
RECOGNIZED_ARMOR_ITEM_IDS_LIST = nil

function Schema:EnsureCorrectArmorState(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local char = ply:GetCharacter()
    if not char then
        if ply:Armor() > 0 then ply:SetArmor(0) end
        return
    end

    local inventory = char:GetInventory()
    if not inventory then
        if ply:Armor() > 0 then ply:SetArmor(0) end
        return
    end

    local hasRecognizedArmorEquipped = false
    local itemsInInventory = inventory:GetItems()

    if not itemsInInventory then
        if ply:Armor() > 0 then ply:SetArmor(0) end
        return
    end

    for instanceInventoryID, itemInstance in pairs(itemsInInventory) do
        if (itemInstance and type(itemInstance) == "table" and itemInstance.IsEquipped) then
            if (itemInstance:IsEquipped()) then
                local itemDefinitionID = itemInstance.uniqueID

                if (itemDefinitionID and ARMOR_ITEM_SET[itemDefinitionID]) then
                    hasRecognizedArmorEquipped = true
                    break
                end
            end
        end
    end

    if not hasRecognizedArmorEquipped then
        if ply:Armor() > 0 then
            local previousArmor = ply:Armor()
            ply:SetArmor(0)
        end
    end
end

hook.Add("PlayerSpawn", "Paragon_ArmorOverride_PlayerSpawn", function(ply)
    timer.Simple(0.3, function()
        if IsValid(ply) then
            Schema:EnsureCorrectArmorState(ply)
        end
    end)
end)

hook.Add("ixPlayerPostCharLoad", "Paragon_ArmorOverride_PostCharLoad", function(ply, char)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            Schema:EnsureCorrectArmorState(ply)
        end
    end)
end)

hook.Add("ixItemEquipped", "Paragon_ArmorOverride_ItemEquipped", function(client, itemInstance, itemEntity, inventory)
    if IsValid(client) then
        timer.Simple(0, function()
            if IsValid(client) then
                 Schema:EnsureCorrectArmorState(client)
            end
        end)
    end
end)

hook.Add("ixItemUnequipped", "Paragon_ArmorOverride_ItemUnequipped", function(client, itemInstance, itemEntity, inventory)
    if IsValid(client) then
        timer.Simple(0, function()
            if IsValid(client) then
                Schema:EnsureCorrectArmorState(client)
            end
        end)
    end
end)

hook.Add("ixItemRemoved", "Paragon_ArmorOverride_ItemRemoved", function(client, itemInstance, itemEntity, inventory)
    if IsValid(client) then
        timer.Simple(0, function()
            if IsValid(client) then
                Schema:EnsureCorrectArmorState(client)
            end
        end)
    end
end)