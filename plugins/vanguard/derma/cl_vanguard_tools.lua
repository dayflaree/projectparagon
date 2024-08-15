/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

// @path plugins/vanguard/derma/cl_vanguard_tools.lua
// @purpose to create a panel for permitted users to restrict tools to certain usergroups

local PLUGIN = PLUGIN

local PANEL = {}

local backgroundColor = Color(0, 0, 0, 66)
function PANEL:Init()
    if ( IsValid(ix.gui.vanguardTools) ) then
        ix.gui.vanguardTools:Remove()
    end

    ix.gui.vanguardTools = self

    self.tools = {}
    self:Dock(FILL)

    local buttons = self:Add("DPanel")
    buttons:Dock(LEFT)
    buttons:SetWide(200)
    buttons:DockMargin(0, 0, 8, 0)
    buttons.maxWidth = 0
    buttons.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)
    end

    self.buttons = buttons

    self:Populate()

    buttons:SetWide(math.min(buttons.maxWidth, ScrW() * 0.15))

    ix.gui.vanguardTools = self
end

function PANEL:Populate()
    local buttons = self.buttons
    buttons:Clear()

    local scroller = buttons:Add("DScrollPanel")
    scroller:Dock(FILL)

    if ( IsValid(self.container) ) then
        self.container:Remove()
    end

    local tools = {}
    local categories = {}
    for k, v in pairs(spawnmenu.GetTools()) do
        for k2, v2 in pairs(v.Items) do
            for k3, v3 in pairs(weapons.Get("gmod_tool").Tool) do
                tools[k3] = v3

                if ( v3.Category ) then
                    categories[v3.Category] = true
                end
            end
        end
    end

    table.sort(categories)
    table.sort(tools)

    for k, v in SortedPairs(categories) do
        local button = scroller:Add("ixVanguardMenuButton")
        button:SetText(k)
        button:SetFont("ixMenuButtonLabelFont")
        button:SizeToContents()
        button:Dock(TOP)
        button.DoClick = function(this)
            self:FilterTools(tools, k)
        end

        buttons.maxWidth = math.max(buttons.maxWidth, button:GetWide())
    end

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)

        if ( #this:GetChildren() < 1 ) then
            derma.SkinFunc("DrawHelixCurved", width / 2, height / 2, width * 0.25)

            surface.SetFont("ixMenuButtonFontSmall")
            local text = L("vanguard_select_tool"):lower()
            local textWidth, textHeight = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width / 2 - textWidth / 2, height / 2 - textHeight / 2)
            surface.DrawText(text)
        end
    end

    self.container = container
end

function PANEL:FilterTools(tools, identifier)
    ix.gui.vanguardToolsLastFilter = identifier

    self.container:Clear()

    local selectedGroup = self.container:Add("DComboBox")
    selectedGroup:SetFont("ixMenuButtonFontSmall")
    selectedGroup:SizeToContents()
    selectedGroup:SetValue(L("vanguard_select_usergroup"))
    selectedGroup:SetSortItems(false)
    selectedGroup:Dock(TOP)

    for k, v in SortedPairsByMemberValue(CAMI.GetUsergroups(), "Order") do
        local value = v.DisplayName or v.Name or k
        selectedGroup:AddChoice(value, k, k == ix.gui.vanguardToolsLastUsergroup)
    end

    selectedGroup.OnSelect = function(this, index, value, data)
        local usergroup = PLUGIN:FindUsergroup(value)
        if ( !usergroup ) then return end

        if ( self.scroller ) then
            self.scroller:Remove()
        end

        self:PopulateTools(tools, identifier, data)

        ix.gui.vanguardToolsLastUsergroup = data
    end

    if ( ix.gui.vanguardToolsLastUsergroup ) then
        self:PopulateTools(tools, identifier, ix.gui.vanguardToolsLastUsergroup)
    end

    self.selectedGroup = selectedGroup

    local restrictAll = self.container:Add("ixVanguardMenuButton")
    restrictAll:SetText(L("vanguard_restrict_all"))
    restrictAll:SetFont("ixMenuButtonLabelFont")
    restrictAll:SizeToContents()
    restrictAll:Dock(TOP)
    restrictAll.DoClick = function(this)
        for k, v in pairs(self.tools) do
            if ( PLUGIN:IsToolRestricted(k, ix.gui.vanguardToolsLastUsergroup) ) then continue end
            
            v:SetValue(true)

            PLUGIN:RestrictTool(k, ix.gui.vanguardToolsLastUsergroup)
        end
    end

    local unrestrictAll = self.container:Add("ixVanguardMenuButton")
    unrestrictAll:SetText(L("vanguard_unrestrict_all"))
    unrestrictAll:SetFont("ixMenuButtonLabelFont")
    unrestrictAll:SizeToContents()
    unrestrictAll:Dock(TOP)
    unrestrictAll.DoClick = function(this)
        for k, v in pairs(self.tools) do
            if ( !PLUGIN:IsToolRestricted(k, ix.gui.vanguardToolsLastUsergroup) ) then continue end

            v:SetValue(false)

            PLUGIN:UnrestrictTool(k, ix.gui.vanguardToolsLastUsergroup)
        end
    end
end

function PANEL:PopulateTools(tools, identifier, usergroup)
    LocalPlayer():EmitSound("Helix.Notify")

    local scroller = self.container:Add("DScrollPanel")
    scroller:Dock(FILL)

    local category = scroller:Add("ixCategoryPanel")
    category:SetText(identifier)
    category:Dock(TOP)
    category:DockMargin(0, 0, 0, 8)

    self.tools = {}

    for k, v in SortedPairs(tools) do
        local name = v.PrintName or v.Name or k
        name = language.GetPhrase(name) or name

        if ( ix.util.StringMatches(v.Category, identifier) ) then
            local button = category:Add("ixVanguardSettingsRowBool")
            button:SetText(name)
            button:SetValue(PLUGIN:IsToolRestricted(k, usergroup))
            button:Dock(TOP)
            button.setting.enabledText = L("vanguard_restricted")
            button.setting.disabledText = L("vanguard_unrestricted")
            button.setting:SizeToContents()
            button.OnValueChanged = function(this, value)
                if ( value ) then
                    PLUGIN:RestrictTool(k, usergroup)
                else
                    PLUGIN:UnrestrictTool(k, usergroup)
                end
            end

            self.tools[k] = button
        end
    end

    category:SizeToContents()

    self.category = category
    self.scroller = scroller
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardTools", PANEL, "DPanel")

if ( IsValid(ix.gui.vanguardTools) ) then
    ix.gui.vanguardTools:Remove()
end