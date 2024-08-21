AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Intercom Hearer"
ENT.Category = "SCPRP"
ENT.Spawnable = true
ENT.AdminOnly = true

if ( SERVER ) then    
    function ENT:Initialize()
        self:SetModel("models/props_wasteland/speakercluster01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()

        if ( IsValid(phys) ) then
            phys:Wake()
        end
    end
end