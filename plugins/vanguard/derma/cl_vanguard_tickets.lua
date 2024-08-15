/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local backgroundColor = Color(0, 0, 0, 66)

local function PopulateMenu(ply)
    local menu = DermaMenu()

    menu:AddOption(L("viewProfile"), function()
        ply:ShowProfile()
    end)

    menu:AddOption(L("copySteamID"), function()
        SetClipboardText(ply:IsBot() and ply:EntIndex() or ply:SteamID())
        ix.util.Notify("Copied SteamID to clipboard.")
    end)

    hook.Run("PopulateScoreboardPlayerMenu", ply, menu)

    menu:Open()
end

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:InvalidateLayout(true)

    self.width, self.height = self:GetSize()

    ix.gui.vanguardTickets = self
end

function PANEL:NoTickets()
    local container = self:Add("DScrollPanel")
    container:Dock(FILL)
    container:DockPadding(8, 8, 8, 8)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)
    end

    local info = container:Add("DLabel")
    info:SetFont("ixSmallFont")
    info:SetText(L("vanguard_tickets_no_actives"))
    info:SetContentAlignment(5)
    info:SetTextColor(color_white)
    info:SetExpensiveShadow(1, color_black)
    info:SizeToContents()
    info:SetTall(info:GetTall() + 16)
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 8)
    info.Paint = function(this, width, height)
        surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", info), 160))
        surface.DrawRect(0, 0, width, height)
    end
end

function PANEL:Populate(width, height)
    self:Clear()

    if ( table.Count(PLUGIN.tickets) == 0 ) then
        self:NoTickets()
        return
    end

    local container = self:Add("DScrollPanel")
    container:Dock(FILL)

    for k, v in pairs(PLUGIN.tickets) do
        local function DoClick()
            local menu = DermaMenu()

            menu:AddOption(L("vanguard_tickets_view"), function()
                self:ViewTicket(width, height, k, v)
            end):SetImage("icon16/application_view_detail.png")

            if ( !v.claimed ) then
                menu:AddOption(L("vanguard_tickets_claim"), function()
                    self:ClaimTicket(k)
                end):SetImage("icon16/user_go.png")
            end

            menu:Open()
        end

        local panel = container:Add("ixCategoryPanel")
        panel:SetTall(96)
        panel:SetText(v.title)
        panel:SetColor(ix.config.Get("color"))
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 16)
        panel:SetMouseInputEnabled(true)
        panel.DoClick = DoClick

        local ply = player.GetBySteamID64(k)
        local avatar = panel:Add(IsValid(ply) and "AvatarImage" or "DPanel")
        avatar:SetSize(64, 64)

        if ( IsValid(ply) ) then
            avatar:SetPlayer(ply, 184)
        else
            avatar.Paint = function(this, width, height)
                surface.SetDrawColor(color_black)
                surface.DrawRect(0, 0, width, height)
            end
        end

        avatar:Dock(LEFT)
        avatar:SetMouseInputEnabled(true)
        avatar.DoClick = DoClick
        avatar.DoRightClick = function(this)
            PopulateMenu(ply)
        end

        local label = panel:Add("DLabel")
        label:SetFont("ixMenuMiniFont")
        label:SetText(v.description)
        label:SetContentAlignment(4)
        label:SetTextColor(color_white)
        label:SetMouseInputEnabled(false)
        label:SetWrap(true)
        label:Dock(FILL)
        label:DockMargin(8, 0, 0, 0)
        label:SetMouseInputEnabled(true)
        label.DoClick = DoClick

        label.DoRightClick = function(this)
            PopulateMenu(ply)
        end
    end
end

function PANEL:ClaimTicket(steamID64)
    net.Start("ixVanguardClaimTicket")
        net.WriteString(steamID64)
    net.SendToServer()
end

function PANEL:ViewTicket(width, height, steamID64, ticket)
    self.lastTicket = steamID64
    self:Clear()

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container:DockPadding(8, 8, 8, 8)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)
    end

    local button = container:Add("ixVanguardMenuButton")
    button:SetText(L("vanguard_back"))
    button:SetFont("ixMenuButtonFontSmall")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(BOTTOM)
    button:DockMargin(-8, 0, -8, -8)
    button.DoClick = function()
        self:Populate(width, height)
    end

    local button = container:Add("ixVanguardMenuButton")
    button:SetText(L("vanguard_tickets_close"))
    button:SetFont("ixMenuButtonFontSmall")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(BOTTOM)
    button:DockMargin(-8, 0, -8, 0)
    button.DoClick = function()
        Derma_Query(L("vanguard_tickets_close_confirm_admin"), "Helix", L("yes"), function()
            net.Start("ixVanguardCloseTicketAdmin")
                net.WriteString(steamID64)
            net.SendToServer()
        end, L("no"))
    end

    local info = container:Add("DPanel")
    info:SetSize(0, 64)
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 8)

    local title = ticket.title
    local description = ticket.description

    local ply = player.GetBySteamID64(steamID64)
    local avatar = info:Add(IsValid(ply) and "AvatarImage" or "DPanel")
    avatar:SetSize(64, 64)
    
    if ( IsValid(ply) ) then
        avatar:SetPlayer(ply, 184)
    else
        avatar.Paint = function(this, width, height)
            surface.SetDrawColor(color_black)
            surface.DrawRect(0, 0, width, height)
        end
    end

    avatar:Dock(LEFT)
    avatar:SetMouseInputEnabled(true)
    avatar.DoClick = DoClick
    avatar.DoRightClick = function(this)
        PopulateMenu(ply)
    end

    if ( ticket.claimed ) then
        local claimedBy = player.GetBySteamID64(ticket.claimedBy)
        local name = IsValid(claimedBy) and claimedBy:Name() or ticket.claimedBy
        
        title = title .. " (" .. L("vanguard_tickets_claimed_by", name) .. ")"
    end

    local titleLabel = info:Add("DLabel")
    titleLabel:SetText(title)
    titleLabel:SetFont("ixSmallFont")
    titleLabel:SetTextColor(color_white)
    titleLabel:SetExpensiveShadow(1, color_black)
    titleLabel:SizeToContents()
    titleLabel:Dock(TOP)
    titleLabel:DockMargin(8, 0, 0, 4)
    titleLabel:SetMouseInputEnabled(true)
    titleLabel.DoClick = function()
        Derma_Message(title, "Helix", "OK")
    end

    titleLabel.DoRightClick = function(this)
        PopulateMenu(ply)
    end

    for id, text in ipairs(ix.util.WrapText(description, width, "ixGenericFont")) do
        local label = info:Add("DLabel")
        label:SetFont("ixGenericFont")
        label:SetText(text)
        label:SetTextColor(color_white)
        label:SizeToContents()
        label:Dock(TOP)
        label:DockMargin(8, 0, 0, 4)
        label:SetMouseInputEnabled(true)
        label.DoClick = function()
            Derma_Message(description, "Helix", "OK")
        end

        label.DoRightClick = function(this)
            PopulateMenu(ply)
        end
    end

    local scroller = container:Add("DScrollPanel")
    scroller:Dock(FILL)
    scroller:DockMargin(0, 0, 0, 8)

    local scrollBar = scroller:GetVBar()
    scrollBar:SetWide(0)

    for k, v in SortedPairs(ticket.replies or {}, true) do
        local panel = scroller:Add("DPanel")
        panel:SetTall(ScreenScale(14))
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 8)

        local bPopulated = false
        panel.Populate = function(this, width, height)
            if ( bPopulated ) then return end
            bPopulated = true

            local ply = player.GetBySteamID64(v.steamID64)
            local avatar = this:Add(IsValid(ply) and "AvatarImage" or "DPanel")
            avatar:SetSize(this:GetTall(), this:GetTall())

            if ( IsValid(ply) ) then
                avatar:SetPlayer(ply, 184)
            else
                avatar.Paint = function(this, width, height)
                    surface.SetDrawColor(color_black)
                    surface.DrawRect(0, 0, width, height)
                end
            end

            local width = width - avatar:GetWide() - 16
            local message = v.reply
            local lines = ix.util.WrapText(message, width, "ixMenuButtonFontSmall")

            local tall = 0
            for id, text in ipairs(lines) do
                local label = this:Add("DLabel")
                label:SetFont("ixMenuButtonFontSmall")
                label:SetText(text)
                label:SetTextColor(color_white)
                label:SizeToContents()
                label:SetTall(this:GetTall())
                label:Dock(TOP)
                label:DockMargin(( id == 1 and avatar:GetWide() or 0 ) + 8, 0, 0, 0)
                label:SetMouseInputEnabled(true)
                label.DoClick = function()
                    Derma_Message(message, "Helix", "OK")
                end
        
                label.DoRightClick = function(this)
                    PopulateMenu(ply)
                end

                tall = tall + label:GetTall()
            end

            this:SetTall(tall)
        end

        panel.Paint = function(this, width, height)
            surface.SetDrawColor(ColorAlpha(color_black, 66))
            surface.DrawRect(0, 0, width, height)

            this:Populate(width, height)
        end
    end

    local button = container:Add("ixVanguardMenuButton")
    button:SetText(L("vanguard_tickets_reply"))
    button:SetFont("ixMenuButtonFontSmall")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(BOTTOM)
    button:DockMargin(-8, 0, -8, 0)
    
    local entry = container:Add("ixTextEntry")
    entry:SetFont("ixMenuButtonFontSmall")
    entry:SizeToContents()
    entry:Dock(BOTTOM)
    entry:DockMargin(0, 0, 0, 8)
    
    button.DoClick = function()
        local reply = entry:GetText()

        if ( reply == "" ) then return end

        net.Start("ixVanguardReplyTicket")
            net.WriteString(steamID64)
            net.WriteString(reply)
        net.SendToServer()

        entry:SetText("")
    end
end

function PANEL:Paint(width, height)
    if ( !self.bPopulated ) then
        self.bPopulated = true
        self.width, self.height = width, height
        self:Populate(width, height)
    end
end

vgui.Register("ixVanguardTickets", PANEL, "DPanel")