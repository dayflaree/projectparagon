ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Intercom"
ENT.Category = "Project Paragon"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Author = "Day"

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsBroadcasting")
end