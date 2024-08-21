AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Intercom"
ENT.Category = "SCPRP"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Enabled")
end

if ( SERVER ) then    
    function ENT:Initialize()
        self:SetModel("models/props_lab/reciever01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetEnabled(false)

        local phys = self:GetPhysicsObject()

        if ( IsValid(phys) ) then
            phys:Wake()
        end
    end
    
    function ENT:Use(ply)
        if ( ( ply.nextIntercomUse or 0 ) < CurTime() ) then
            self:SetEnabled((!self:GetEnabled()))
            
            if ( self:GetEnabled() ) then
                ply:Notify("The intercom is now on.")
            else
                ply:Notify("The intercom is now off.")
            end
            
            ply.nextIntercomUse = CurTime() + 1.5 
        end
    end
end