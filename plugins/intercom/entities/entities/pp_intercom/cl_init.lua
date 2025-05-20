include("shared.lua")

function ENT:Draw()
    self:DrawModel() -- Standard model drawing

    -- Optional: Add some text if it's broadcasting
    if (self:GetIsBroadcasting()) then
        local ang = self:GetAngles()
        local pos = self:GetPos() + ang:Up() * 20 -- Adjust position as needed

        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), -90)

        -- cam.Start3D2D(pos, ang, 0.1)
        --     draw.SimpleTextOutlined("BROADCASTING", "DermaLarge", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
        -- cam.End3D2D()
    end
end

-- Optional: If you want client-side sounds tied to the entity's state changes
function ENT:OnIsBroadcastingChanged(oldVal, newVal)
    if newVal == true then
        -- Could play a local "power on" sound for the entity model
    else
        -- Could play a local "power off" sound
    end
end

function ENT:OnRestore() end -- For save/load if needed
function ENT:OnRemove() end   -- Cleanup if needed