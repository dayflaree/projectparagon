/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local classes = {
    ["prop_dynamic"] = true,
    ["prop_dynamic_override"] = true,
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

local physicsClasses = {
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

function PLUGIN:PhysgunDrop(ply, ent)
    if ( CLIENT ) then return end
    if ( !IsValid(ent) ) then return end

    if ( ent:IsPlayer() and CAMI.PlayerHasAccess(ply, "Helix - Vanguard Props - Bypass", nil) ) then
        ent:SetMoveType(MOVETYPE_WALK)
        return
    end

    if ( !classes[ent:GetClass()] ) then return end

    // find all constrainted entities from the entity and do the same
    local entities = {}
    for k, v in pairs(constraint.GetAllConstrainedEntities(ent)) do
        if ( !IsValid(v) ) then continue end
        if ( !classes[v:GetClass()] ) then continue end

        local oldColor = v:GetNetVar("oldColor")
        local oldCollisionGroup = v:GetNetVar("oldCollisionGroup")
        local oldRenderMode = v:GetNetVar("oldRenderMode")
        local oldRenderFX = v:GetNetVar("oldRenderFX")

        v:SetColor(oldColor or Color(255, 255, 255, 255))
        v:SetCollisionGroup(oldCollisionGroup or COLLISION_GROUP_NONE)
        v:SetRenderMode(oldRenderMode or RENDERMODE_NORMAL)
        v:SetRenderFX(oldRenderFX or kRenderFxNone)

        table.insert(entities, v)
    end

    net.Start("ixVanguardPhysgunDrop")
        net.WritePlayer(ply)
        net.WriteTable(entities)
    net.Broadcast()
end

function PLUGIN:VanguardPhysicsCollide(ent1, ent2)
    if ( !IsValid(ent1) or !IsValid(ent2) ) then return end
    if ( !physicsClasses[ent1:GetClass()] or !physicsClasses[ent2:GetClass()] ) then return end

    local owner1 = ent1:GetNetVar("Vanguard.Owner")
    local owner2 = ent2:GetNetVar("Vanguard.Owner")
    if ( !IsValid(owner1) or !IsValid(owner2) ) then return end
    if ( owner1 != owner2 ) then return end

    local phys1 = ent1:GetPhysicsObject()
    local phys2 = ent2:GetPhysicsObject()

    if ( !IsValid(phys1) or !IsValid(phys2) ) then return end
    if ( !phys1:IsMotionEnabled() or !phys2:IsMotionEnabled() ) then return end
    if ( phys1:IsAsleep() or phys2:IsAsleep() ) then return end

    if ( phys1:IsPenetrating() or phys2:IsPenetrating() ) then
        if ( IsValid(owner1) and IsValid(owner2) ) then
            if ( ( owner1.ixNextMessage or 0 ) < CurTime() ) then
                self:SendChatLog(owner1, color_white, " owned a prop that was stuck in another prop, it has been removed.")
                owner1.ixNextMessage = CurTime() + 1
            end

            if ( ( owner2.ixNextMessage or 0 ) < CurTime() ) then
                self:SendChatLog(owner2, color_white, " owned a prop that was stuck in another prop, it has been removed.")
                owner2.ixNextMessage = CurTime() + 1
            end

            if ( rb655_dissolve ) then
                rb655_dissolve(ent1)
                rb655_dissolve(ent2)
            end

            ent1:SetCollisionGroup(COLLISION_GROUP_WORLD)
            ent2:SetCollisionGroup(COLLISION_GROUP_WORLD)

            ent1:EmitSound("ambient/levels/labs/electric_explosion1.wav", 60, math.random(120, 130))
            ent2:EmitSound("ambient/levels/labs/electric_explosion1.wav", 60, math.random(120, 130))
        end

        return
    end

    // if there is more than 10 props near the prop, freeze them all
    local count = 0
    for k, v in ipairs(ents.FindInSphere(ent1:GetPos(), 64)) do
        if ( !IsValid(v) ) then continue end
        if ( !physicsClasses[v:GetClass()] ) then continue end
        if ( v == ent1 or v == ent2 ) then continue end

        count = count + 1
    end

    if ( count > 10 ) then
        for k, v in ipairs(ents.FindInSphere(ent1:GetPos(), 64)) do
            if ( !IsValid(v) ) then continue end
            if ( !physicsClasses[v:GetClass()] ) then continue end
            if ( v == ent1 or v == ent2 ) then continue end

            local phys = v:GetPhysicsObject()
            if ( IsValid(phys) ) then
                phys:EnableMotion(false)
            end

            local effect = EffectData()
            effect:SetEntity(v)
            util.Effect("entity_remove", effect)

            v:EmitSound("ambient/energy/weld1.wav", 60, math.random(120, 130))
        end

        if ( IsValid(owner1) ) then
            if ( ( owner1.ixNextMessage or 0 ) < CurTime() ) then
                self:SendChatLog(owner1, color_white, " is trying to spawn too many props in one place, their props have been frozen.")
                owner1.ixNextMessage = CurTime() + 1
            end
        end

        if ( IsValid(owner2) ) then
            if ( ( owner2.ixNextMessage or 0 ) < CurTime() ) then
                self:SendChatLog(owner2, color_white, " is trying to spawn too many props in one place, their props have been frozen.")
                owner2.ixNextMessage = CurTime() + 1
            end
        end
    end
end

function PLUGIN:PhysgunPickup(ply, ent)
    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Props - Bypass", nil) ) then
        return true
    end

    if ( !IsValid(ent) ) then return false end
    if ( !IsValid(ply) ) then return false end
    if ( ent:IsPlayer() ) then return false end

    if ( ent:GetNetVar("Vanguard.Owner") == ply ) then
        return true
    end
end

function PLUGIN:PrePACConfigApply(ply)
    local cami = CAMI.PlayerHasAccess(ply, "Helix - Vanguard PAC3 - Edit", nil)
    if ( !cami ) then
        ply:Notify("You are not permitted to use apply PAC3 changes!")
        return false
    end
end

local pac = ix.plugin.Get("pac")
if ( pac ) then
    function pac:PrePACEditorOpen()
    end

    function pac:pac_CanWearParts()
    end
end

function PLUGIN:PrePACEditorOpen(ply)
    local cami = CAMI.PlayerHasAccess(ply, "Helix - Vanguard PAC3 - View", nil)
    if ( !cami ) then
        ply:Notify("You are not permitted to use the PAC3 editor!")
        return false
    end
end

function PLUGIN:pac_CanWearParts(ply)
    local cami = CAMI.PlayerHasAccess(ply, "Helix - Vanguard PAC3 - Edit", nil)
    if ( !cami ) then
        ply:Notify("You are not permitted to wear PAC3 parts!")
        return false
    end
end

function PLUGIN:OnPlayerHitGround(ply, inWater, onFloater, speed)
    if not ( ix.config.Get("antiBunnyhop") ) then
        return
    end

    local amount = ix.config.Get("antiBunnyhopStrength", 0.5)
    local vel = ply:GetVelocity()
    ply:SetVelocity(Vector(-( vel.x * amount ), - ( vel.y * amount ), 0))
end

hook.Add("CAMI.PlayerHasAccess", "Vanguard.CAMI.PlayerHasAccess", function(ply, privilege, callback)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then callback(false) end

    local userGroup = ply:GetUserGroup()
    if ( !userGroup ) then callback(false) end

    local userGroupData = CAMI.GetUsergroup(userGroup)
    if ( !userGroupData or !istable(userGroupData) ) then callback(false) end

    local permissions = PLUGIN.permissions
    if ( !permissions or !istable(permissions) ) then callback(false) end

    if ( permissions[privilege] and istable(permissions[privilege]) ) then
        if ( table.HasValue(permissions[privilege], userGroup) ) then
            callback(true)
        else
            callback(false)
        end
    else
        callback(false)
    end

    return true
end)