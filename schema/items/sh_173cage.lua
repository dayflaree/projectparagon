ITEM.name = "Containment Cage"
ITEM.uniqueID = "scp173_containment_cage"
ITEM.model = "models/cpthazama/scp/items/173_box.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Tools"

local function OnCanRun(client)
    if ( !IsValid(client) or !client:Alive() ) then
        ErrorNoHaltWithStack("Capture failed: Invalid client or client not alive.")
        return false
    end

    local trace = client:GetEyeTrace()
    if ( !IsValid(trace.Entity) or trace.Entity:GetClass() != "npc_cpt_scp_173" ) then
        return false
    end

    local targetSCP173 = trace.Entity
    local distance = client:GetShootPos():DistToSqr(targetSCP173:WorldSpaceCenter())
    local captureRange = 128 ^ 2
    if ( distance > captureRange ) then
        return false
    end

    local targetPoint = targetSCP173:WorldSpaceCenter()
    local toSCPVector = (targetPoint - client:EyePos()):GetNormalized()
    local aimDotProduct = client:GetAimVector():Dot(toSCPVector)
    local requiredDotProduct = 0.65
    if ( aimDotProduct < requiredDotProduct ) then
        return false
    end

    if ( targetSCP173.IsContained ) then
        return false
    end

    if ( !IsValid(targetSCP173) ) then
        return false
    end

    return true
end

ITEM.functions.Capture = {
    name = "Capture",
    OnRun = function(item)
        local client = item.player
        local trace = client:GetEyeTrace()
        local targetSCP173 = trace.Entity

        client:SetAction("Capturing SCP-173...", 30)
        client:DoStaredAction(targetSCP173, function()
            if ( !OnCanRun(client) ) then
                ErrorNoHaltWithStack("Capture failed: OnCanRun check failed.")
                return false
            end

            targetSCP173.IsContained = true
            targetSCP173:CPT_StopMovement()
            targetSCP173:SetVelocity(vector_origin)

            if ( IsValid(targetSCP173.IdleMoveSound) and targetSCP173.IdleMoveSound.Stop ) then
                targetSCP173.IdleMoveSound:Stop()
            end

            targetSCP173:SetActivity(ACT_IDLE)

            local cageEntity = ents.Create("ent_scp173_captured_cage")
            if ( !IsValid(cageEntity) ) then
                ErrorNoHaltWithStack("Failed to create ent_scp173_captured_cage entity.")

                if ( IsValid(targetSCP173) ) then
                    targetSCP173.IsContained = false
                end

                return false
            end

            cageEntity:SetPos(targetSCP173:GetPos())
            cageEntity:SetAngles(targetSCP173:GetAngles())
            cageEntity:Spawn()

            cageEntity:SetOwnerPlayer(client)
            cageEntity:SetCapturedSCP(targetSCP173)

            local zOffset = 10

            targetSCP173:SetParent(cageEntity)
            targetSCP173:SetLocalPos(Vector(0, 0, zOffset))
            targetSCP173:SetLocalAngles(Angle(0, 0, 0))

            targetSCP173:SetSolid(SOLID_NONE)
            targetSCP173:SetMoveType(MOVETYPE_NONE)
            targetSCP173:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            client:EmitSound("projectparagon/sfx/Door/BigDoorStartsOpenning.ogg")
            item:Remove()
        end, 30, function()
            client:SetAction()

            local character = client:GetCharacter()
            if ( !character ) then
                ErrorNoHaltWithStack("Capture failed: Invalid character.")
                return false
            end

            local inventory = character:GetInventory()
            if ( !inventory ) then
                ErrorNoHaltWithStack("Capture failed: Invalid inventory.")
                return false
            end

            if ( !inventory:Add(item.uniqueID, 1) ) then
                ix.item.Spawn(item.uniqueID, client)
            end
        end, 128)

        return true
    end,
    OnCanRun = function(item)
        return OnCanRun(item.player)
    end
}