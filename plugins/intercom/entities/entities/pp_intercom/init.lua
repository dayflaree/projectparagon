AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/scp/map/control_panel_2.mdl") -- Placeholder model, change as needed!
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE) -- Allows +use to trigger ENT:Use

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:Wake()
    end

    self:SetIsBroadcasting(false)
end

function ENT:Use(activator, caller)
    if (IsValid(activator) and activator:IsPlayer()) then
        local intercomPlugin = ix.plugin.Get("intercom") -- Get the plugin instance
        if (intercomPlugin) then
            intercomPlugin:PlayerAttemptUseIntercom(activator, self) -- Pass entity if needed for state
        else
            activator:Notify("Intercom system plugin is not loaded!")
            ErrorNoHalt("[Project Paragon Intercom] Intercom plugin 'intercom' not found!\n")
        end
    end
end

-- Optional: If you want the entity to visually react or play sounds itself
function ENT:StartBroadcastVisuals()
    self:EmitSound(ix.plugin.Get("intercom").soundBroadcastStart or "")
    self:SetIsBroadcasting(true)
    -- You could change skin, bodygroups, emit particles, etc.
end

function ENT:StopBroadcastVisuals()
    self:EmitSound(ix.plugin.Get("intercom").soundBroadcastEnd or "")
    self:SetIsBroadcasting(false)
    -- Revert visual changes
end