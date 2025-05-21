ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "SCP-173 (Contained)"
ENT.Category = "Project Paragon Entities"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "OwnerPlayer")
    self:NetworkVar("Entity", 1, "CapturedSCP")
    self:NetworkVar("Bool", 0, "IsBeingCarried")
end