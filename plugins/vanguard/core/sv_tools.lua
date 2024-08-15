/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local all = {
    ["duplicator"] = true,
    ["dynamite"] = true,
    ["eyeposer"] = true,
    ["faceposer"] = true,
    ["fingerposer"] = true,
    ["inflator"] = true,
    ["paint"] = true,
    ["physprop"] = true,
    ["trails"] = true,
    ["wire_detonator"] = true,
    ["wire_detonators"] = true,
    ["wire_egp"] = true,
    ["wire_explosive"] = true,
    ["wire_expression2"] = true,
    ["wire_eyepod"] = true,
    ["wire_field_device"] = true,
    ["wire_hsholoemitter"] = true,
    ["wire_hsranger"] = true,
    ["wire_magnet"] = true,
    ["wire_pod"] = true,
    ["wire_simple_explosive"] = true,
    ["wire_soundemitter"] = true,
    ["wire_spu"] = true,
    ["wire_teleporter"] = true,
    ["wire_trail"] = true,
    ["wire_trigger"] = true,
    ["wire_turret"] = true,
    ["wire_user"] = true,
    ["wnpc"] = true
}

local default = {}

hook.Add("VanguardTools.OnUsergroupRegistered", "CAMI.OnUsergroupRegistered", function(usergroup, source)
    if ( !default[usergroup] ) then
        default[usergroup] = all
    end
end)

function PLUGIN:GetTools()
    for k, v in pairs(CAMI.GetUsergroups()) do
        default[k] = all
    end

    return ix.data.Get("restricted_tools", default, false, true, true)
end

function PLUGIN:GetToolsForUsergroup(usergroup)
    local tools = self:GetTools()

    return tools[usergroup] or {}
end

function PLUGIN:GetToolsDefault()
    return default
end

function PLUGIN:ResetTools()
    for k, v in pairs(CAMI.GetUsergroups()) do
        default[k] = all
    end

    ix.data.Set("restricted_tools", default, false, true)
    self:SyncTools()

    return default
end

function PLUGIN:SetTools(tools)
    if ( !tools ) then
        for k, v in pairs(CAMI.GetUsergroups()) do
            default[k] = all
        end
        
        tools = default
    end

    ix.data.Set("restricted_tools", tools, false, true)

    return tools
end

function PLUGIN:RestrictTool(tool, usergroup)
    local tools = self:GetTools()

    if ( !tools[usergroup] ) then
        tools[usergroup] = {}
    end

    tools[usergroup][tool] = true

    self:SetTools(tools)
    self:SyncTools()

    return tools, tools[usergroup]
end

function PLUGIN:UnrestrictTool(tool, usergroup)
    local tools = self:GetTools()

    if ( tools[usergroup] ) then
        tools[usergroup][tool] = nil

        self:SetTools(tools)
        self:SyncTools()
    end

    return tools, tools[usergroup]
end

function PLUGIN:IsToolRestricted(tool, usergroup)
    local tools = self:GetTools()
    if ( tools[usergroup] ) then
        return tools[usergroup][tool]
    end

    return false
end

function PLUGIN:CanTool(ply, trace, tool)
    local usergroup = ply:GetUserGroup()

    if ( self:IsToolRestricted(tool, usergroup) ) then
        return false
    end
end

function PLUGIN:SyncTools()
    net.Start("ixVanguardToolsSync")
        net.WriteTable(self:GetTools())
        net.WriteTable(self:GetToolsDefault())
    net.Broadcast()
end

util.AddNetworkString("ixVanguardToolsSync")
util.AddNetworkString("ixVanguardToolsRestrict")
util.AddNetworkString("ixVanguardToolsUnrestrict")

net.Receive("ixVanguardToolsRestrict", function(_, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tools - Restrict", nil) ) then return end

    local tool = net.ReadString()
    local usergroup = net.ReadString()

    PLUGIN:RestrictTool(tool, usergroup)

    ply:NotifyLocalized("vanguard_tool_restrict_callback", tool, usergroup)
end)

net.Receive("ixVanguardToolsUnrestrict", function(_, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tools - Unrestrict", nil) ) then return end

    local tool = net.ReadString()
    local usergroup = net.ReadString()

    PLUGIN:UnrestrictTool(tool, usergroup)

    ply:NotifyLocalized("vanguard_tool_unrestrict_callback", tool, usergroup)
end)