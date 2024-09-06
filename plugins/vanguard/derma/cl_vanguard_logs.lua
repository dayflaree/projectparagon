/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
    self.page = 0

    self:Dock(FILL)

    local requestData = self:Add("ixVanguardMenuButton")
    requestData:Dock(TOP)
    requestData:DockMargin(0, 0, 0, 8)
    requestData:SetText("vanguard_logs_request")
    requestData:SetFont("ixMenuButtonFontSmall")
    requestData:SetContentAlignment(5)
    requestData:SizeToContentsY()
    requestData.DoClick = function(this)
        net.Start("ixVanguardRequestLogs")
        net.SendToServer()
    end

    local info = self:Add("DLabel")
    info:SetFont("ixSmallFont")
    info:SetText(L("vanguard_logs_info"))
    info:SetContentAlignment(5)
    info:SetTextColor(color_white)
    info:SetExpensiveShadow(1, color_black)
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 8)
    info:SizeToContents()
    info:SetTall(info:GetTall() + 16)

    info.Paint = function(this, width, height)
        surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", this), 160))
        surface.DrawRect(0, 0, width, height)
    end

    local searchEntry = self:Add("ixIconTextEntry")
    searchEntry:Dock(TOP)
    searchEntry:SetEnterAllowed(false)

    searchEntry.OnChange = function(this)
        self:FilterLogs(this:GetValue())
    end

    self.searchEntry = searchEntry

    local logsList = self:Add("DScrollPanel")
    logsList:Dock(FILL)
    logsList:DockMargin(0, 8, 0, 0)
    logsList.Paint = function(this, width, height)
        if ( #self.logsList:GetCanvas():GetChildren() == 0 ) then
            derma.SkinFunc("DrawHelixCurved", width / 2, height / 2, width * 0.25)

            surface.SetFont("ixIntroSubtitleFont")
            local text = L("vanguard_no_logs"):lower()
            local textWidth, textHeight = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width / 2 - textWidth / 2, height / 2 - textHeight / 2)
            surface.DrawText(text)
        end
    end

    self.logsList = logsList

    local bottom = self:Add("DPanel")
    bottom:Dock(BOTTOM)
    bottom:DockMargin(0, 8, 0, 0)
    bottom.Paint = nil
    
    local previousPage = bottom:Add("ixVanguardMenuButton")
    previousPage:Dock(LEFT)
    previousPage:SetText("vanguard_logs_previous")
    previousPage:SetFont("ixMenuButtonFontSmall")
    previousPage:SetWide(ScrW() / 4)
    previousPage:SetContentAlignment(5)
    previousPage:SizeToContentsY()
    previousPage.DoClick = function(this)
        self.page = math.max(0, self.page - 1)
        self:PopulateLogs(self.page, searchEntry:GetValue())
    end

    local nextPage = bottom:Add("ixVanguardMenuButton")
    nextPage:Dock(RIGHT)
    nextPage:SetText("vanguard_logs_next")
    nextPage:SetFont("ixMenuButtonFontSmall")
    nextPage:SetWide(ScrW() / 4)
    nextPage:SetContentAlignment(5)
    nextPage:SizeToContentsY()
    nextPage.DoClick = function(this)
        self.page = self.page + 1
        self:PopulateLogs(self.page, searchEntry:GetValue())
    end

    local pageLabel = bottom:Add("DLabel")
    pageLabel:Dock(FILL)
    pageLabel:SetFont("ixMenuButtonFontSmall")
    pageLabel:SetText("Page 0")
    pageLabel:SetContentAlignment(5)
    pageLabel:SetTextColor(color_white)
    pageLabel:SetMouseInputEnabled(false)
    pageLabel.Think = function(this)
        this:SetText(L("vanguard_logs_page", self.page, self.pageMax))
    end

    bottom:SetTall(nextPage:GetTall())

    self:PopulateLogs(self.page)

    ix.gui.vanguardLogs = self
end

function PANEL:FilterLogs(search)
    self:PopulateLogs(self.page, search)
end

local stringMatches = ix.util.StringMatchesTable
function PANEL:PopulateLogs(page, filter)
    self.logsList:GetCanvas():Clear()
    self.page = page

    local logs = PLUGIN.logs or {}
    for k, v in SortedPairs(logs) do
        local logText, logPage = v.line, v.page

        if ( self.page != logPage ) then
            continue
        end

        if ( filter and !stringMatches(logText, filter) ) then
            continue
        end

        local panel = self.logsList:Add("DPanel")
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 4)
        panel:SetTall(24)
        panel:SetMouseInputEnabled(true)

        panel.OnMousePressed = function(this, code)
            local menu = DermaMenu()

            menu:AddOption(L("vanguard_copy_to_clipboard"), function()
                SetClipboardText(logText)
            end)

            for k2, v2 in player.Iterator() do
                local searchFor = v2:IsBot() and v2:Name() or v2:SteamID()
                if not ( stringMatches(logText, searchFor) or stringMatches(logText, v2:Name()) ) then
                    continue
                end

                menu:AddSpacer()

                local label = menu:Add("DLabel")
                label:SetText(v2:Name())
                label:SetFont("Default")
                label:SetContentAlignment(5)
                label:SetTextColor(color_white)
                label:SetMouseInputEnabled(false)
                
                menu:AddPanel(label)

                menu:AddOption(L("viewProfile"), function()
                    v2:ShowProfile()
                end)
        
                menu:AddOption(L("copySteamID"), function()
                    SetClipboardText(v2:IsBot() and v2:EntIndex() or v2:SteamID())
                end)
        
                hook.Run("PopulateScoreboardPlayerMenu", v2, menu)
            end

            menu:Open()
        end

        panel.Paint = function(this, width, height)
            surface.SetDrawColor(0, 0, 0, 66)
            surface.DrawRect(0, 0, width, height)
        end

        local label = panel:Add("DLabel")
        label:Dock(FILL)
        label:DockMargin(4, 0, 0, 0)
        label:SetFont("ixGenericFont")
        label:SetText(logText)
        label:SetContentAlignment(4)
        label:SetTextColor(color_white)
        label:SetMouseInputEnabled(false)
    end

    self.pageMax = 0
    for k, v in SortedPairs(logs) do
        if ( v.page > self.pageMax ) then
            self.pageMax = v.page
        end
    end
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardLogs", PANEL, "DPanel")