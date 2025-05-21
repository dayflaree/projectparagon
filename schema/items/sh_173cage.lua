-- File: sh_item_scp173_cage.lua

ITEM.name = "Containment Cage"
ITEM.uniqueID = "scp173_containment_cage"
ITEM.model = "models/cpthazama/scp/items/173_box.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Tools"

ITEM.functions.Capture = {
    name = "Capture",
    tip = "captureTip",
    icon = "icon16/arrow_down.png",
    OnRun = function(item)
        local ply = item.player
        if not IsValid(ply) or not ply:Alive() then return false end

        local trace = ply:GetEyeTrace()

        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "npc_cpt_scp_173" then
            ply:Notify("No valid target.")
            return false
        end

        local targetSCP173 = trace.Entity
        local distance = ply:GetShootPos():Distance(targetSCP173:WorldSpaceCenter())
        local captureRange = 120
        if distance > captureRange then
            ply:Notify("Target is too far away. (Dist: " .. string.format("%.0f", distance) .. "/" .. captureRange .. ")")
            return false
        end

        local targetPoint = targetSCP173:WorldSpaceCenter()
        local toSCPVector = (targetPoint - ply:EyePos()):GetNormalized()
        local aimDotProduct = ply:GetAimVector():Dot(toSCPVector)
        local requiredDotProduct = 0.65

        if aimDotProduct < requiredDotProduct then
            ply:Notify("You must be looking more directly at target. (Aim Dot: " .. string.format("%.2f", aimDotProduct) .. "/" .. requiredDotProduct .. ")")
            return false
        end

        -- =================================================================
        -- DISABLE SCP-173's AI USING ITS NATIVE 'IsContained' FLAG
        -- =================================================================
        if not IsValid(targetSCP173) then return false end

        targetSCP173.IsContained = true -- This should make its OnThink() return early
        targetSCP173:CPT_StopMovement() -- Stop any current movement/schedule
        targetSCP173:SetVelocity(vector_origin)
        if IsValid(targetSCP173.IdleMoveSound) and targetSCP173.IdleMoveSound.Stop then -- Stop its movement sound
            targetSCP173.IdleMoveSound:Stop()
        end
        targetSCP173:SetActivity(ACT_IDLE) -- Set to idle animation
        print("[SCP173 Cage] Set targetSCP173.IsContained = true")
        -- =================================================================

        local cageEntity = ents.Create("ent_scp173_captured_cage")
        if not IsValid(cageEntity) then
            ply:Notify("Failed to create containment cage entity.")
            if IsValid(targetSCP173) then
                targetSCP173.IsContained = false -- Revert if cage fails
            end
            return false
        end

        cageEntity:SetPos(targetSCP173:GetPos())
        cageEntity:SetAngles(targetSCP173:GetAngles())
        cageEntity:Spawn()

        cageEntity:SetOwnerPlayer(ply)
        cageEntity:SetCapturedSCP(targetSCP173)
            
        local zOffset = 10 -- TEST AND ADJUST THIS VALUE!

        targetSCP173:SetParent(cageEntity)
        targetSCP173:SetLocalPos(Vector(0, 0, zOffset))
        targetSCP173:SetLocalAngles(Angle(0, 0, 0)) 

        targetSCP173:SetSolid(SOLID_NONE)
        targetSCP173:SetMoveType(MOVETYPE_NONE) 
        targetSCP173:SetCollisionGroup(COLLISION_GROUP_DEBRIS) 

        ply:EmitSound("projectparagon/sfx/Door/BigDoorStartsOpenning.ogg") 
        item:Remove()

        return true 
    end,
    OnCanRun = function(item)
        local ply = item.player
        return IsValid(ply) and ply:Alive() and not IsValid(item.entity)
    end
}