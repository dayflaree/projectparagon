-- File: ent_scp173_captured_cage/init.lua

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SCP173_Cage_PlayerAttemptUse")

function ENT:Initialize()
    self:SetModel("models/cpthazama/scp/items/173_box.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) -- Changed SOLID_NONE to SOLID_VPHYSICS
    self:SetMoveType(MOVETYPE_NOCLIP)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    self:SetIsBeingCarried(true)
    self.isBeingReleased = false -- New flag
end

function ENT:SetOwnerPlayer(ply)
    self:SetOwner(ply)
    self.m_OwnerPlayer = ply
end

function ENT:GetOwnerPlayer()
    return self.m_OwnerPlayer or self:GetOwner()
end

function ENT:SetCapturedSCP(scp)
    self.m_CapturedSCP = scp
end

function ENT:GetCapturedSCP()
    return self.m_CapturedSCP
end

function ENT:Think()
    if not self:GetIsBeingCarried() then return end
    if self.isBeingReleased then return end -- If already being released, don't process think

    local owner = self:GetOwnerPlayer()
    if not IsValid(owner) or not owner:Alive() then
        if not self.isBeingReleased then -- Only call ReleaseSCP if not already in process
            self:ReleaseSCP(self:GetPos() + self:GetForward() * 30, nil)
        end
        return 
    end
    local targetDist = 80 
    local cageHeightRelativeToPlayerOrigin = 5 
    local positionFollowSpeed = 1
    local angleFollowSpeed = 1.2
    local ownerPos = owner:GetPos()
    local playerBodyAngles = owner:GetAngles() 
    local bodyForwardVector = Angle(0, playerBodyAngles.y, 0):Forward()
    local desiredCagePos = ownerPos - (bodyForwardVector * targetDist) + Vector(0, 0, cageHeightRelativeToPlayerOrigin)
    local currentCagePos = self:GetPos()
    local newCagePos = LerpVector(FrameTime() * positionFollowSpeed, currentCagePos, desiredCagePos)
    self:SetPos(newCagePos)
    local currentCageFullAngle = self:GetAngles()
    local targetCageFullAngle = Angle(0, playerBodyAngles.y, 0) 
    local newCageFullAngle = LerpAngle(FrameTime() * angleFollowSpeed, currentCageFullAngle, targetCageFullAngle)
    local finalCageAngle = Angle(0, newCageFullAngle.y, 0)
    self:SetAngles(finalCageAngle)
    self:NextThink(CurTime())
    return true
end

function ENT:ReleaseSCP(releasePos, playerToReceiveItem)
    if self.isBeingReleased then return end -- Prevent re-entry
    self.isBeingReleased = true -- Set flag

    local scpEntity = self:GetCapturedSCP()
    if IsValid(scpEntity) then -- Only proceed if there was an SCP to release
        self.m_CapturedSCP = nil -- Clear reference early
        scpEntity:SetParent(nil)
        if IsValid(scpEntity) then scpEntity:SetPos(releasePos) end
        if IsValid(scpEntity) then scpEntity:SetAngles(Angle(0, self:GetAngles().y, 0)) end
        if IsValid(scpEntity) then
            scpEntity.IsContained = false
            scpEntity:SetNPCState(NPC_STATE_IDLE) 
            scpEntity:SetSchedule(SCHED_IDLE_STAND) 
        end
        if IsValid(scpEntity) then scpEntity:SetSolid(SOLID_BBOX) end
        if IsValid(scpEntity) then scpEntity:SetMoveType(MOVETYPE_STEP) end
        if IsValid(scpEntity) then scpEntity:SetCollisionGroup(COLLISION_GROUP_NPC) end
        if IsValid(scpEntity) then scpEntity:SetVelocity(vector_origin) end
        if IsValid(scpEntity) then
            if scpEntity.SetNextThink and type(scpEntity.SetNextThink) == "function" then
                scpEntity:SetNextThink(CurTime() + 0.1)
            end
        end
    end

    -- if IsValid(playerToReceiveItem) and playerToReceiveItem:IsPlayer() and playerToReceiveItem:Alive() then
    --     if (playerToReceiveItem.GiveItem and type(playerToReceiveItem.GiveItem) == "function") then
    --         local itemTable = playerToReceiveItem:GiveItem("scp173_containment_cage")
    --         if itemTable then
    --             playerToReceiveItem:Notify("SCP-173 released. Containment cage returned.")
    --         else
    --             playerToReceiveItem:Notify("SCP-173 released. Error returning cage item (inventory full or already have one?).")
    --         end
    --     else
    --         local plyByID = Player(playerToReceiveItem:UserID())
    --         if IsValid(plyByID) and plyByID:IsPlayer() and plyByID.GiveItem then
    --             local itemTable = plyByID:GiveItem("scp173_containment_cage")
    --             if itemTable then plyByID:Notify("SCP-173 released. Cage returned (fallback).") else plyByID:Notify("SCP-173 released. Cage return error (fallback).") end
    --         end
    --     end
    -- end

    -- Final action: Remove the cage entity
    if IsValid(self) then -- Check IsValid one last time before calling Remove
        self:EmitSound("projectparagon/sfx/Door/BigDoorStartsOpenning.ogg") 
        self:Remove()
    end
end

function ENT:OnRemove()
    -- This function is called by the engine when self:Remove() is processed.
    -- We should avoid calling self:Remove() again inside here.
    -- The main purpose now is to ensure the SCP is truly free if it was somehow still linked.
    if self.isBeingReleased then return end -- If ReleaseSCP initiated the removal, its logic is enough.

    local scpEntity = self:GetCapturedSCP() 
    if IsValid(scpEntity) then
        if scpEntity:GetParent() == self then -- Only unparent if it's still parented to this cage
            scpEntity:SetParent(nil)
        end
        local safePos = self:GetPos()
        local tr = util.TraceLine({start = self:GetPos(), endpos = self:GetPos() - Vector(0,0,100), mask = MASK_SOLID_BRUSHONLY})
        if tr.Hit then safePos = tr.HitPos + Vector(0,0,5) end
        if IsValid(scpEntity) then scpEntity:SetPos(safePos) end
        if IsValid(scpEntity) then
            scpEntity.IsContained = false 
            scpEntity:SetNPCState(NPC_STATE_IDLE)
        end
        if IsValid(scpEntity) then scpEntity:SetSolid(SOLID_BBOX) end
        if IsValid(scpEntity) then scpEntity:SetMoveType(MOVETYPE_STEP) end
        if IsValid(scpEntity) then scpEntity:SetCollisionGroup(COLLISION_GROUP_NPC) end
        if IsValid(scpEntity) and scpEntity.SetNextThink and type(scpEntity.SetNextThink) == "function" then
            scpEntity:SetNextThink(CurTime())
        end
    end
end

net.Receive("SCP173_Cage_PlayerAttemptUse", function(len, ply)
    if not IsValid(ply) or not ply:Alive() or not ply:IsPlayer() then return end

    local cageEntity = net.ReadEntity()
    if not IsValid(cageEntity) or cageEntity:GetClass() ~= "ent_scp173_captured_cage" then return end
    
    if cageEntity:GetOwnerPlayer() == ply then
        if not cageEntity.isBeingReleased then -- Check flag before calling
            cageEntity:ReleaseSCP(cageEntity:GetPos() + cageEntity:GetForward() * 30, ply)
        end
    else
        ply:Notify("This is not your captured SCP-173 to release.")
    end
end)