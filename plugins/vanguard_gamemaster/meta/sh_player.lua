/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PLAYER = FindMetaTable("Player")

if ( SERVER ) then
    return
end

PLAYER.CanOverrideViewOld = PLAYER.CanOverrideViewOld or PLAYER.CanOverrideView
function PLAYER:CanOverrideView()
    if ( self:GetNetVar("scenesPlaying") or self.scenesPlaying ) then
        return false
    end

    return self:CanOverrideViewOld()
end