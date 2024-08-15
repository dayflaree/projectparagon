/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

local backgroundColor = Color(0, 0, 0, 66)
function PANEL:Init()
    if ( IsValid(ix.gui.vanguardSequences) ) then
        ix.gui.vanguardSequences:Remove()
    end

    ix.gui.vanguardSequences = self

    self:Dock(FILL)

    local buttons = self:Add("DPanel")
    buttons:Dock(TOP)
    buttons:DockMargin(0, 0, 0, 8)
    buttons.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 66)
        surface.DrawRect(0, 0, width, height)
    end

    self.buttons = buttons

    self:Populate()

    ix.gui.vanguardSequences = self
end

function PANEL:Populate()
    local buttons = self.buttons

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Add event")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/add.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(RIGHT)
    button.DoClick = function()
    end

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Clear all events")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/cross.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(RIGHT)
    button.DoClick = function()
    end

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Save as file")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/disk.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(RIGHT)
    button.DoClick = function()
    end

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Load from file")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/folder.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(RIGHT)
    button.DoClick = function()
    end

    buttons:SizeToChildren(false, true)
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardSequences", PANEL, "DPanel")

if ( IsValid(ix.gui.vanguardSequences) ) then
    ix.gui.vanguardSequences:Remove()
end