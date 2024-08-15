/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:PlayerKick(ply, target, reason)
    if ( !reason or reason == "" ) then
        reason = "No reason provided."
    end

    if ( target == ply ) then
        ply:NotifyLocalized("vanguard_cannot_kick_self")
        return
    end

    local can, err = hook.Run("CanPlayerTarget", ply, target)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    target:Kick(reason)
    ply:NotifyLocalized("vanguard_kicked", target:Name(), reason)

    self:SendChatLog(ply, color_white, " has kicked ", target, color_white, " for: \"" .. reason .. "\".")
end