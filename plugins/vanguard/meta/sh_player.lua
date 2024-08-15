/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PLAYER = FindMetaTable("Player")

function PLAYER:SendChatLog(...)
    if ( !ix.config.Get("chatLogs", true) ) then
        return
    end

    if ( ix.config.Get("chatLogsAdminOnly", true) and !CAMI.PlayerHasAccess(self, "Helix - Vanguard Logs", nil) ) then
        return
    end

    local args = {}
    args[#args + 1] = ix.config.Get("vanguardColor")
    args[#args + 1] = "[VANGUARD] "

    args[#args + 1] = Color(255, 255, 255)

    for _, v in ipairs({...}) do
        args[#args + 1] = v
    end

    net.Start("ixVanguardLogsChat")
        net.WriteTable(args)
    net.Send(self)
end

function PLAYER:IsDonator()
    local group = self:GetUserGroup()
    local camiGroup = CAMI.GetUsergroup(group)
    if ( !camiGroup ) then
        return group == "donator" or group == "admin" or group == "superadmin"
    end

    return tobool(camiGroup.DonatorPrivileges)
end

function PLAYER:IsAdmin()
    local group = self:GetUserGroup()
    local camiGroup = CAMI.GetUsergroup(group)
    if ( !camiGroup ) then
        return group == "admin"
    end

    local adminGroup = CAMI.GetUsergroup("admin")
    if ( !adminGroup ) then
        return group == "admin"
    end

    if ( camiGroup.Order and adminGroup.Order and camiGroup.Order > adminGroup.Order ) then
        return true
    end

    return group == "admin" or camiGroup.Inherits == "admin" or self:IsSuperAdmin()
end

function PLAYER:IsSuperAdmin()
    local group = self:GetUserGroup()
    local camiGroup = CAMI.GetUsergroup(group)
    if ( !camiGroup ) then
        return group == "superadmin"
    end

    local superadminGroup = CAMI.GetUsergroup("superadmin")
    if ( !superadminGroup ) then
        return group == "superadmin"
    end

    if ( camiGroup.Order and superadminGroup.Order and camiGroup.Order > superadminGroup.Order ) then
        return true
    end

    return group == "superadmin" or camiGroup.Inherits == "superadmin"
end