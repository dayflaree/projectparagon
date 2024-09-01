local PLUGIN = PLUGIN

PLUGIN.name = "Heads Up Displays"
PLUGIN.description = "Contains all heads up displays."
PLUGIN.author = "pkz.0z"

-- This might be a lil bit messy but I'm adding more shit in to it. Any code that looks a lil bit silly I will fix up!!! Do not touch unless I've made a retarded error

if not ( CLIENT ) then return end

function PLUGIN:ShouldHideBars()
    return true
end

function PLUGIN:DrawGenHud(ply)

end

function PLUGIN:DrawNTFHud(ply, gall)
    draw.DrawText("hi", "DermaDefault", 10, 10)
end

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    local char = ply:GetCharacter()

    if not ( IsValid(ply) and char ) then return end
    
    for i, v in ipairs(player.GetAll()) do
        PLUGIN:DrawGenHud(ply)

        if ply:IsE11() then
            self:DrawNTFHud(ply, v)
        end
    end
end