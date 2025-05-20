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

hook.Add("Think", "ClampFactionHealthAndArmor", function()
    for _, ply in ipairs(player.GetAll()) do
        local char = ply:GetCharacter()
        if not char then continue end

        local faction = ix.faction.indices[char:GetFaction()]
        if not faction then continue end

        -- Clamp Health
        if faction.maxHealth and ply:Health() > faction.maxHealth then
            ply:SetHealth(faction.maxHealth)
        end

        -- Clamp Armor
        if faction.maxArmor and ply:Armor() > faction.maxArmor then
            ply:SetArmor(faction.maxArmor)
        end
    end
end)