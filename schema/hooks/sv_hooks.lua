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
        ix.log.Add(client, "chat", chatType and chatType:utf8upper() or "??", message) -- Changed 'text or message' to 'message'
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

local EXEMPT_FACTION_INDICES = {
    [FACTION_SECURITY] = true,
    [FACTION_MTF] = true,
    [FACTION_CI] = true,
}

function Schema:EnsureCorrectArmorState(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local char = ply:GetCharacter()
    if not char then
        if ply:Armor() > 0 then ply:SetArmor(0) end
        return
    end

    local playerFactionIndex = char:GetFaction()
    if EXEMPT_FACTION_INDICES[playerFactionIndex] then
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
        if (itemInstance and type(itemInstance) == "table" and itemInstance.isEquipped) then -- Changed IsEquipped to isEquipped (field access)
            -- if (itemInstance:isEquipped()) then -- Assuming isEquipped is a field, not a method. Changed :IsEquipped() to .isEquipped
            local itemDefinitionID = itemInstance.uniqueID

            if (itemDefinitionID and ARMOR_ITEM_SET[itemDefinitionID]) then
                hasRecognizedArmorEquipped = true
                break
            end
            -- end
        end
    end

    if not hasRecognizedArmorEquipped then
        if ply:Armor() > 0 then
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

local ammoListForSaving = {}

local function RegisterAmmoForSaving(name)
    name = name:lower()
    if (!table.HasValue(ammoListForSaving, name)) then
        ammoListForSaving[#ammoListForSaving + 1] = name
    end
end

RegisterAmmoForSaving("ar2")
RegisterAmmoForSaving("pistol")
RegisterAmmoForSaving("357")
RegisterAmmoForSaving("smg1")
RegisterAmmoForSaving("xbowbolt")
RegisterAmmoForSaving("buckshot")
RegisterAmmoForSaving("rpg_round")
RegisterAmmoForSaving("smg1_grenade")
RegisterAmmoForSaving("grenade")
RegisterAmmoForSaving("ar2altfire")
RegisterAmmoForSaving("slam")
RegisterAmmoForSaving("alyxgun")
RegisterAmmoForSaving("sniperround")
RegisterAmmoForSaving("sniperpenetratedround")
RegisterAmmoForSaving("thumper")
RegisterAmmoForSaving("gravity")
RegisterAmmoForSaving("battery")
RegisterAmmoForSaving("gaussenergy")
RegisterAmmoForSaving("combinecannon")
RegisterAmmoForSaving("airboatgun")
RegisterAmmoForSaving("striderminigun")
RegisterAmmoForSaving("helicoptergun")

local raiseAllWeapons_Bypass = {
    ["ix_hands"] = true,
}

if (_G.ALWAYS_RAISED == nil) then
    _G.ALWAYS_RAISED = {}
elseif (type(_G.ALWAYS_RAISED) ~= "table") then
     _G.ALWAYS_RAISED = {}
end

local HOOKS = {}

function HOOKS:CharacterPreSave(character)
    local client = character:GetPlayer()

    if (IsValid(client)) then
        local ammoTable = {}

        for _, ammoType in ipairs(ammoListForSaving) do
            local ammoCount = client:GetAmmoCount(ammoType)

            if (ammoCount > 0) then
                ammoTable[ammoType] = ammoCount
            end
        end

        character:SetData("ammo", ammoTable)
    end
end

function HOOKS:PlayerLoadedCharacter(client)
    timer.Simple(0.25, function()
        if (!IsValid(client)) then
            return
        end

        local character = client:GetCharacter()
        if (!character) then
            return
        end

        local ammoTable = character:GetData("ammo")

        if (ammoTable and type(ammoTable) == "table") then
            for ammoType, ammoCount in pairs(ammoTable) do
                client:SetAmmo(ammoCount, tostring(ammoType))
            end
        end
    end)
end

hook.Add("PostPlayerLoadout", "Paragon_StripKeys_PostPlayerLoadout_FromPlugin", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) and ply:IsPlayer() then
            if ply:HasWeapon("ix_keys") then
                ply:StripWeapon("ix_keys")
            end
        end
    end)
end)

function HOOKS:PlayerSwitchWeapon(ply, oldWep, newWep)
    if not (IsValid(newWep) and newWep:IsWeapon()) then -- Changed check to IsWeapon()
        return
    end

    local newWepClass = newWep:GetClass()

    if (raiseAllWeapons_Bypass[newWepClass]) then
        return
    end
    _G.ALWAYS_RAISED[newWepClass] = true
end

return HOOKS