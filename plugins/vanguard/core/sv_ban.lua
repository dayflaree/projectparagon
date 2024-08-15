/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:PlayerBan(ply, target, reason, duration)
    if ( !reason or reason == "" ) then
        reason = "No reason provided."
    end

    if ( target == ply ) then
        ply:NotifyLocalized("vanguard_cannot_ban_self")
        return
    end

    local can, err = hook.Run("CanPlayerTarget", ply, target)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    if ( VyHub ) then
        VyHub.Ban:create(target:SteamID64(), duration, reason or "No reason provided.", ply:SteamID64())
        VyHub.Ban:kick_banned_players()

        ply:NotifyLocalized("vanguard_banned", target:Name(), reason, string.NiceTime(duration))

        return
    end

    target:Ban(duration)
    target:Kick(reason)

    ply:NotifyLocalized("vanguard_banned", target:Name(), reason, string.NiceTime(duration))

    self:SendChatLog(ply, color_white, " has banned ", target, color_white, " for: \"" .. reason .. "\".")
end