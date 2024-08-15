/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

// comment: taken from the areas plugin
function PLUGIN:GetLocalAreaPosition(startPosition, endPosition)
    local center = LerpVector(0.5, startPosition, endPosition)
    local min = WorldToLocal(startPosition, angle_zero, center, angle_zero)
    local max = WorldToLocal(endPosition, angle_zero, center, angle_zero)

    return center, min, max
end

function PLUGIN:FindEmptySpace(position, filter, spacing, size, height, tolerance)
    spacing = spacing or 24
    size = size or 4
    height = height or 36
    tolerance = tolerance or 1

    return ix.util.FindEmptySpace(position, filter, spacing, size, height, tolerance)
end

function PLUGIN:PlayerTeleportTo(ply, target, pos, filter, spacing, size, height, tolerance)
    if ( !pos ) then
        ply:NotifyLocalized("vanguard_no_pos")
        return
    end

    local positions = self:FindEmptySpace(pos, {target}, spacing, size, height, tolerance)
    if ( !positions ) then
        ply:NotifyLocalized("vanguard_no_space")
        return
    end

    pos = positions[math.random(1, #positions)]
    if ( !pos ) then
        ply:NotifyLocalized("vanguard_no_pos")
        return
    end

    local trace = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 32768),
        filter = target
    })

    pos = trace.HitPos

    target.ixReturnPos = target:GetPos()
    target:SetPos(pos)
    target:SetEyeAngles((ply:EyePos() - target:EyePos()):Angle())

    local wep = target:GetActiveWeapon()
    if ( IsValid(wep) ) then
        if ( target:KeyDown(IN_ATTACK) ) then
            target:ConCommand("-attack")
        end

        target:SetWepRaised(false, wep)
    end

    local effectdata = EffectData()
    effectdata:SetEntity(target)
    effectdata:SetStart(pos)
    effectdata:SetOrigin(pos)
    effectdata:SetScale(1)
    util.Effect("entity_remove", effectdata)

    return pos
end

function PLUGIN:PlayerTeleportToArea(ply, target, area)
    local areas = ix.area.stored
    if ( table.IsEmpty(areas) ) then
        ply:NotifyLocalized("vanguard_no_areas")
        return
    end

    local bFoundArea
    local areaData
    for k, v in pairs(areas) do
        if ( ix.util.StringMatches(k, area) ) then
            bFoundArea = true
            areaData = {k, v}
            break
        end
    end

    if ( bFoundArea and areaData ) then
        local center, min, max = self:GetLocalAreaPosition(areaData[2].startPosition, areaData[2].endPosition)
        local pos = center

        if ( self:PlayerTeleportTo(ply, target, pos, nil, 64, 10, 64, 64) ) then
            ply:NotifyLocalized("vanguard_teleport_to_area", target:GetName(), areaData[1])
            target:NotifyLocalized("vanguard_teleport_to_area_target", areaData[1])
        else
            ply:NotifyLocalized("vanguard_no_space")
        end
    else
        ply:NotifyLocalized("vanguard_no_area")
    end
end

function PLUGIN:PlayerTeleportToTarget(ply, target1, target2)
    if ( target1 == target2 ) then
        ply:NotifyLocalized("vanguard_same_target")
        return
    end

    local positions = self:FindEmptySpace(target2:GetPos(), {ply, target1, target2})
    if ( !positions ) then
        ply:NotifyLocalized("vanguard_no_space")
        return
    end

    local pos = positions[math.random(1, #positions)]
    if ( !pos ) then
        ply:NotifyLocalized("vanguard_no_pos")
        return
    end

    if ( self:PlayerTeleportTo(ply, target1, pos) ) then
        ply:NotifyLocalized("vanguard_teleport_target", target1:GetName(), target2:GetName())
        target1:NotifyLocalized("vanguard_teleport_target_to", ply:GetName(), target2:GetName())
    else
        ply:NotifyLocalized("vanguard_no_space")
    end
end

function PLUGIN:PlayerBring(ply, target)
    local positions = self:FindEmptySpace(ply:GetPos(), {ply, target})
    if ( !positions ) then
        ply:NotifyLocalized("vanguard_no_space")
        return
    end

    local pos = positions[math.random(1, #positions)]
    if ( !pos ) then
        ply:NotifyLocalized("vanguard_no_pos")
        return
    end

    if ( self:PlayerTeleportTo(ply, target, pos) ) then
        ply:NotifyLocalized("vanguard_teleport_bring", target:GetName())

        if ( ply != target ) then
            target:NotifyLocalized("vanguard_teleport_bring_target", ply:GetName())
        end
    else
        ply:NotifyLocalized("vanguard_no_space")
    end
end

function PLUGIN:PlayerGoto(ply, target)
    local positions = self:FindEmptySpace(target:GetPos(), {ply, target})
    if ( !positions ) then
        ply:NotifyLocalized("vanguard_no_space")
        return
    end

    local pos = positions[math.random(1, #positions)]
    if ( !pos ) then
        ply:NotifyLocalized("vanguard_no_pos")
        return
    end

    if ( self:PlayerTeleportTo(target, ply, pos) ) then
        ply:NotifyLocalized("vanguard_teleport_goto", target:GetName())

        if ( ply != target ) then
            target:NotifyLocalized("vanguard_teleport_goto_target", ply:GetName())
        end
    else
        ply:NotifyLocalized("vanguard_no_space")
    end
end

function PLUGIN:PlayerReturn(ply, target)
    if ( !target.ixReturnPos ) then
        ply:NotifyLocalized("vanguard_no_return_pos", target:GetName())
        return
    end

    if ( self:PlayerTeleportTo(ply, target, target.ixReturnPos) ) then
        ply:NotifyLocalized("vanguard_teleport_return", target:GetName())
        target:NotifyLocalized("vanguard_teleport_return_target", ply:GetName())

        target.ixReturnPos = nil
    else
        ply:NotifyLocalized("vanguard_no_space")
    end
end