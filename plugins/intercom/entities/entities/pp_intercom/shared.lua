ENT.Type = "anim"
ENT.Base = "base_gmodentity" -- Or "base_anim" if you prefer

ENT.PrintName = "Intercom Panel"
ENT.Category = "Project Paragon" -- For your Q menu

ENT.Spawnable = true
ENT.AdminOnly = true -- Set to false if non-admins can spawn it

ENT.Author = "Day"

ENT.RenderGroup = RENDERGROUP_OPAQUE -- Or RENDERGROUP_TRANSLUCENT if it has transparency

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsBroadcasting") -- To potentially show state on client
end