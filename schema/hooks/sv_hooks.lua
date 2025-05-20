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

function Schema:PostPlayerSay(client, chatType, message, anonymous)
    if (chatType == "ic") then
        ix.log.Add(client, "chat", chatType and chatType:utf8upper() or "??", text or message)
    end
end

function Schema:CanPlayerThrowPunch()
    return false
end

function Schema:PlayerInteractItem(ply, action, item)
    if (action == "take") then
        if (item.interactSounds and istable(item.interactSounds)) then
            ply:EmitSound(item.interactSounds[math.random(1, #item.interactSounds)])
        end
    end
end

function Schema:PlayerModelChanged(ply, model)
    if (not IsValid(ply) or ply:IsBot()) then return end
    ply:SetupHands()
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

hook.Add("PostPlayerLoadout", "Paragon_RemoveDefaultKeys", function(ply, char, loadout)
    if not IsValid(ply) then return end
    local keysWeaponClass = "ix_keys"
    timer.Simple(0.1, function()
        if IsValid(ply) then
            if ply:HasWeapon(keysWeaponClass) then
                ply:StripWeapon(keysWeaponClass)
            end
        end
    end)
end)

hook.Add("ShouldCollide", "Paragon_ItemNoCollide", function(entity1, entity2)
    if (IsValid(entity1) and IsValid(entity2) and
        entity1:GetClass() == "ix_item" and entity2:GetClass() == "ix_item") then
        return false
    end
end)

local SchemaAmmoToSave = SchemaAmmoToSave or {}

function Schema:RegisterAmmoTypeForSaving(ammoName)
    ammoName = ammoName:lower()
    if (!table.HasValue(SchemaAmmoToSave, ammoName)) then
        SchemaAmmoToSave[#SchemaAmmoToSave + 1] = ammoName
    end
end

Schema:RegisterAmmoTypeForSaving("ar2")
Schema:RegisterAmmoTypeForSaving("pistol")
Schema:RegisterAmmoTypeForSaving("357")
Schema:RegisterAmmoTypeForSaving("smg1")
Schema:RegisterAmmoTypeForSaving("xbowbolt")
Schema:RegisterAmmoTypeForSaving("buckshot")
Schema:RegisterAmmoTypeForSaving("rpg_round")
Schema:RegisterAmmoTypeForSaving("smg1_grenade")
Schema:RegisterAmmoTypeForSaving("grenade")
Schema:RegisterAmmoTypeForSaving("ar2altfire")
Schema:RegisterAmmoTypeForSaving("slam")

Schema:RegisterAmmoTypeForSaving("alyxgun")
Schema:RegisterAmmoTypeForSaving("sniperround")
Schema:RegisterAmmoTypeForSaving("sniperpenetratedround")
Schema:RegisterAmmoTypeForSaving("thumper")
Schema:RegisterAmmoTypeForSaving("gravity")
Schema:RegisterAmmoTypeForSaving("battery")
Schema:RegisterAmmoTypeForSaving("gaussenergy")
Schema:RegisterAmmoTypeForSaving("combinecannon")
Schema:RegisterAmmoTypeForSaving("airboatgun")
Schema:RegisterAmmoTypeForSaving("striderminigun")
Schema:RegisterAmmoTypeForSaving("helicoptergun")

hook.Add("CharacterPreSave", "Paragon_SaveCharacterAmmo", function(character)
    local client = character:GetPlayer()

    if (IsValid(client)) then
        local ammoTableToSave = {}

        for _, ammoName in ipairs(SchemaAmmoToSave) do
            local currentAmmoCount = client:GetAmmoCount(ammoName)

            if (currentAmmoCount > 0) then
                ammoTableToSave[ammoName] = currentAmmoCount
            end
        end

        if next(ammoTableToSave) then
            character:SetData("savedAmmo", ammoTableToSave)
        else
            character:SetData("savedAmmo", nil)
        end
    end
end)

hook.Add("ixPlayerPostCharLoad", "Paragon_RestoreCharacterAmmo", function(client, character)
    timer.Simple(0.25, function()
        if (!IsValid(client) or !client:IsPlayer()) then
            return
        end

        local currentChar = client:GetCharacter()
        if (!currentChar) then
            return
        end

        local savedAmmoTable = currentChar:GetData("savedAmmo")

        if (savedAmmoTable) then
            for ammoName, ammoCount in pairs(savedAmmoTable) do
                client:SetAmmo(ammoCount, ammoName)
            end
        end
    end)
end)

local WeaponsToBypassAlwaysRaised = {
    ["ix_hands"] = true,
}

hook.Add("PlayerSwitchWeapon", "Paragon_ForceRaiseWeapon", function(ply, oldWeapon, newWeapon)
    if (not IsValid(newWeapon)) then
        return
    end

    local weaponClass = newWeapon:GetClass()

    if (WeaponsToBypassAlwaysRaised[weaponClass]) then
        return
    end

    if (weaponClass and weaponClass ~= "") then
        ALWAYS_RAISED[weaponClass] = true
    end
end)

hook.Add("ixPlayerPostCharLoad", "Paragon_InitialWeaponRaiseCheck", function(client, character)
    if (IsValid(client)) then
        timer.Simple(0.1, function()
            if (IsValid(client)) then
                for _, weaponEnt in ipairs(client:GetWeapons()) do
                    if (IsValid(weaponEnt)) then
                        local weaponClass = weaponEnt:GetClass()
                        if (weaponClass and weaponClass ~= "" and not WeaponsToBypassAlwaysRaised[weaponClass]) then
                            ALWAYS_RAISED[weaponClass] = true
                        end
                    end
                end
            end
        end)
    end
end)

hook.Add("PlayerAuthed", "Paragon_AntiFamilyShare", function(ply, steamID, uniqueID)
    if not IsValid(ply) then return end

    local ownerSteamID64 = ply:OwnerSteamID64()
    local playerSteamID64 = ply:SteamID64()

    if (ownerSteamID64 == playerSteamID64) then
        return
    end

    local kickMessage = "Family shared accounts are not permitted on this server."
    ply:Kick(kickMessage)

    local logMessage = string.format("%s (%s / %s) kicked for family sharing. IP: %s. Owner: %s",
        ply:Nick(), ply:SteamID(), playerSteamID64, ply:IPAddress(), ownerSteamID64)
    print("[Paragon AntiFamilyShare] " .. logMessage)

    local schemaFolder = Schema and Schema.Folder or "projectparagon"
    local logDirectory = "helix/" .. schemaFolder .. "/familyshared/"
    local logFilePath = logDirectory .. playerSteamID64 .. "_" .. ownerSteamID64 .. ".txt"

    if not file.IsDir(logDirectory, "DATA") then
        file.CreateDir(logDirectory, "DATA")
    end

    local logTable = {
        timestamp = os.time(),
        date = os.date("%Y-%m-%d %H:%M:%S"),
        playerName = ply:Nick(),
        playerSteamID = ply:SteamID(),
        playerSteamID64 = playerSteamID64,
        playerIP = ply:IPAddress(),
        ownerSteamID64 = ownerSteamID64,
        kickReason = kickMessage
    }
    file.Write(logFilePath, util.TableToJSON(logTable, true))

    local adminNotifyMessage = string.format("%s was kicked for using a family shared account (Owner: %s).", ply:Nick(), ownerSteamID64)
    for _, adminPlayer in ipairs(player.GetAll()) do
        if (adminPlayer:IsAdmin()) then
            adminPlayer:ChatPrint("[AntiFamilyShare] " .. adminNotifyMessage)
        end
    end
end)