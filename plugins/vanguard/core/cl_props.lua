/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.blacklistedModels = PLUGIN.blacklistedModels or {}

net.Receive("ixVanguardBlacklistedModelsSync", function()
    PLUGIN.blacklistedModels = net.ReadTable()

    for k, v in pairs(PLUGIN.blacklistedModels) do
        util.PrecacheModel(k)
    end
end)

function PLUGIN:GetBlacklistedModels()
    return self.blacklistedModels
end

function PLUGIN:BlacklistModel(model)
    net.Start("ixVanguardBlacklistedModelsAdd")
        net.WriteString(model)
    net.SendToServer()
end

function PLUGIN:UnblacklistModel(model)
    net.Start("ixVanguardBlacklistedModelsRemove")
        net.WriteString(model)
    net.SendToServer()
end

function PLUGIN:IsModelBlacklisted(model)
    local data = self:GetBlacklistedModels()
    return data[model:lower()]
end

local classes = {
    ["prop_dynamic"] = true,
    ["prop_dynamic_override"] = true,
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

net.Receive("ixVanguardPhysgunPickup", function()
    local ply = net.ReadPlayer()
    if ( !IsValid(ply) ) then return end

    local entities = net.ReadTable()
    if ( !entities or table.IsEmpty(entities) ) then return end

    for _, ent in ipairs(entities) do
        if ( !IsValid(ent) ) then continue end

        ent:SetColor(ColorAlpha(ix.config.Get("vanguardColor"), 200))
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ent:SetRenderFX(kRenderFxHologram)

        local effect = EffectData()
        effect:SetEntity(ent)
        util.Effect("entity_remove", effect)
    end
end)

net.Receive("ixVanguardPhysgunDrop", function()
    local ply = net.ReadPlayer()
    if ( !IsValid(ply) ) then return end

    local entities = net.ReadTable()
    if ( !entities or table.IsEmpty(entities) ) then return end

    for _, ent in ipairs(entities) do
        if ( !IsValid(ent) ) then continue end

        local oldColor = ent:GetNetVar("oldColor")
        local oldCollisionGroup = ent:GetNetVar("oldCollisionGroup")
        local oldRenderMode = ent:GetNetVar("oldRenderMode")
        local oldRenderFX = ent:GetNetVar("oldRenderFX")

        ent:SetColor(oldColor or Color(255, 255, 255, 255))
        ent:SetCollisionGroup(oldCollisionGroup or COLLISION_GROUP_NONE)
        ent:SetRenderMode(oldRenderMode or RENDERMODE_NORMAL)
        ent:SetRenderFX(oldRenderFX or kRenderFxNone)

        local effect = EffectData()
        effect:SetEntity(ent)
        util.Effect("entity_remove", effect)
    end
end)