/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.tools = PLUGIN.tools or {}
PLUGIN.toolsDefault = PLUGIN.toolsDefault or {}

net.Receive("ixVanguardToolsSync", function()
    PLUGIN.tools = net.ReadTable()
    PLUGIN.toolsDefault = net.ReadTable()
end)

function PLUGIN:GetTools()
    return self.tools
end

function PLUGIN:GetToolsForUsergroup(usergroup)
    local tools = self:GetTools()

    return tools[usergroup] or {}
end

function PLUGIN:GetToolsDefault()
    return self.toolsDefault
end

function PLUGIN:RestrictTool(tool, usergroup)
    net.Start("ixVanguardToolsRestrict")
        net.WriteString(tool)
        net.WriteString(usergroup)
    net.SendToServer()
end

function PLUGIN:UnrestrictTool(tool, usergroup)
    net.Start("ixVanguardToolsUnrestrict")
        net.WriteString(tool)
        net.WriteString(usergroup)
    net.SendToServer()
end

function PLUGIN:CanTool(ply, trace, tool)
    if ( !IsValid(ply) ) then return end

    local usergroup = ply:GetUserGroup()
    local data = self.tools[tool]

    if ( data ) then
        if ( data[usergroup] ) then
            return true
        end

        return false
    end
end

function PLUGIN:IsToolRestricted(tool, usergroup)
    local tools = self:GetTools()
    if ( tools[usergroup] ) then
        return tobool(tools[usergroup][tool])
    end

    return false
end