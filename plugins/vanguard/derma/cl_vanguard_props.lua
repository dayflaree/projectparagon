/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local props = {}
    for k, v in pairs(PLUGIN:GetBlacklistedModels()) do
        k = k:utf8lower()

        table.insert(props, k)
    end

    table.sort(props, function(a, b)
        return a:utf8lower() < b:utf8lower()
    end)

    self.props = props

    self:Populate()

    ix.gui.vanguardProps = self
end

local stringMatches = ix.util.StringMatches // comment: gets called alot, so we localize it to save performance
function PANEL:Populate()
    local searchEntry = self:Add("ixIconTextEntry")
    searchEntry:Dock(TOP)
    searchEntry:SetEnterAllowed(false)

    searchEntry.OnChange = function(this)
        self:PopulateProps(this:GetValue())
    end

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 66)
        surface.DrawRect(0, 0, width, height)
    end

    local propScroller = container:Add("DScrollPanel")
    propScroller:Dock(FILL)
    propScroller.VBar:SetWide(0)

    self.propList = propScroller:Add("DIconLayout")
    self.propList:Dock(TOP)
    self.propList:InvalidateParent()

    timer.Simple(0.1, function()
        self:PopulateProps(ix.gui.vanguardPropsLastFilter or "")
    end)
end

function PANEL:PopulateProps(filter)
    self.propList:Clear()

    local size = self.propList:GetWide() / 16
    for k, v in ipairs(self.props) do
        v = v:utf8lower()

        if ( filter and !stringMatches(v, filter) ) then continue end

        local button = self.propList:Add("ixVanguardMenuButton")
        button:SetSize(size, size)
        button:SetText("")
        button.DoClick = function(this)
            Derma_Query(L("vanguard_spawn_model_confirm", v), "Helix", L("yes"), function()
                RunConsoleCommand("gm_spawn", v)
            end, L("no"))
        end
        button.DoRightClick = function(this)
            local menu = DermaMenu()

            menu:AddOption(L("vanguard_copy_to_clipboard"), function()
                SetClipboardText(v)
            end):SetIcon("icon16/page_copy.png")

            if ( PLUGIN:IsModelBlacklisted(v) ) then
                menu:AddOption(L("vanguard_unblacklist"), function()
                    Derma_Query(L("vanguard_unblacklist_model_confirm", v), "Helix", L("yes"), function()
                        PLUGIN:UnblacklistModel(v)
                    end, L("no"))
                end):SetIcon("icon16/cancel.png")
            else
                menu:AddOption(L("vanguard_blacklist"), function()
                    Derma_Query(L("vanguard_blacklist_model_confirm", v), "Helix", L("yes"), function()
                        PLUGIN:BlacklistModel(v)
                    end, L("no"))
                end):SetIcon("icon16/accept.png")
            end

            menu:AddOption(L("vanguard_model_viewer"), function()
                self:OpenModelViewer(v)
            end):SetIcon("icon16/picture.png")

            menu:Open()
        end

        button:SetHelixTooltip(function(tooltip)
            local name = tooltip:AddRow("name")
            name:SetText(L("vanguard_blacklisted"))
            name:SetBackgroundColor(ix.config.Get("color"))
            name:SizeToContents()

            local description = tooltip:AddRow("description")
            description:SetText(v)
            description:SizeToContents()
        end)

        local icon = button:Add("ixSpawnIcon")
        icon:Dock(FILL)
        icon:SetModel(v)
        icon:SetMouseInputEnabled(false)
    end

    ix.gui.vanguardPropsLastFilter = filter
end

local function BestGuessLayout(panel, ent)
    if ( !IsValid(ent) ) then return end

    local pos = ent:GetPos()
    local ang = ent:GetAngles()

    ent:SetAngles(ang)

    local tab = PositionSpawnIcon(ent, pos, true)
    if ( tab ) then
        panel:SetCamPos(tab.origin)
        panel:SetFOV(tab.fov)
        panel:SetLookAng(tab.angles)
    end
end

function PANEL:OpenModelViewer(model)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() / 3, ScrH() / 2)
    frame:SetTitle(L("vanguard_model_viewer") .. " (" .. model .. ")")
    frame:Center()
    frame:MakePopup()

    local panel = frame:Add("DAdjustableModelPanel")
    panel:Dock(FILL)
    panel:SetModel(model)
    panel:SetFOV(45)
    panel:SetCamPos(Vector(50, 50, 50))
    panel:SetLookAt(Vector(0, 0, 0))
    panel.LayoutEntity = function(this, ent)
    end

    local ent = panel.Entity
    if ( IsValid(ent) ) then
        BestGuessLayout(panel, ent)
    end
end

function PANEL:Paint()
end

vgui.Register("ixVanguardProps", PANEL, "DPanel")