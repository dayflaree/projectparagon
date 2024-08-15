/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.tickets = PLUGIN.tickets or {}

net.Receive("ixVanguardSyncTickets", function()
    local tickets = net.ReadTable()

    PLUGIN.tickets = tickets

    local panel = PLUGIN.ticketPanel
    if ( IsValid(panel) ) then
        PLUGIN:PopulateTickets(panel, panel.width, panel.height)
    end

    local panel = ix.gui.vanguardTickets
    if ( IsValid(panel) ) then
        if ( panel.lastTicket and tickets[panel.lastTicket] ) then
            local ticket = tickets[panel.lastTicket]
            if ( ticket ) then
                panel:ViewTicket(panel.width, panel.height, panel.lastTicket, ticket)
            end
        else
            panel:Populate(panel.width, panel.height)
        end
    end
end)

function PLUGIN:PopulateTickets(container, width, height)
    container.width = width or container.width
    container.height = height or container.height

    container:Clear()

    if ( !container:GetCanvas():IsVisible() ) then
        for _, v in ipairs(container:GetChildren()) do
            if ( v == container:GetCanvas() ) then continue end
            if ( v == container:GetVBar() ) then continue end

            v:Remove()
        end
    end

    self.ticketPanel = container

    local ply = LocalPlayer()
    local steamID64 = ply:SteamID64()

    local bActiveTicket = self.tickets[steamID64]
    if ( bActiveTicket ) then
        local button = container:Add("ixMenuButton")
        button:SetText(L("vanguard_tickets_close"))
        button:SetFont("ixMenuButtonFontSmall")
        button:SetContentAlignment(5)
        button:SizeToContents()
        button:Dock(BOTTOM)
        button:DockMargin(-8, 0, -8, -8)
        button.DoClick = function()
            Derma_Query(L("vanguard_tickets_close_confirm"), "Helix", L("yes"), function()
                net.Start("ixVanguardCloseTicket")
                net.SendToServer()
            end, L("no"))
        end

        local title = bActiveTicket.title
        local description = bActiveTicket.description

        local titleLabel = container:Add("DLabel")
        titleLabel:SetText(title)
        titleLabel:SetFont("ixMenuButtonFontSmall")
        titleLabel:SetContentAlignment(5)
        titleLabel:SetTextColor(color_white)
        titleLabel:SetExpensiveShadow(1, color_black)
        titleLabel:SizeToContents()
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 0, 0, 8)

        for id, text in ipairs(ix.util.WrapText(description, width, "ixGenericFont")) do
            local label = container:Add("DLabel")
            label:SetFont("ixGenericFont")
            label:SetText(text)
            label:SetTextColor(color_white)
            label:SizeToContents()
            label:Dock(TOP)
            label:DockMargin(0, 0, 0, 8)
        end

        local scroller = container:Add("DScrollPanel")
        scroller:Dock(FILL)
        scroller:DockMargin(0, 0, 0, 8)

        local scrollBar = scroller:GetVBar()
        scrollBar:SetWide(0)

        for k, v in SortedPairs(bActiveTicket.replies or {}, true) do
            local panel = scroller:Add("DPanel")
            panel:SetTall(ScreenScale(14))
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 8)

            local bPopulated = false
            panel.Populate = function(this, width, height)
                if ( bPopulated ) then return end
                bPopulated = true

                local avatar = this:Add("AvatarImage")
                avatar:SetSize(this:GetTall(), this:GetTall())
                avatar:SetPlayer(player.GetBySteamID64(v.steamID64), 184)
    
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

        local button = container:Add("ixMenuButton")
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
    elseif ( self.bCreatingTicket ) then
        local info = container:Add("DLabel")
        info:Dock(TOP)
        info:DockMargin(0, 0, 0, 8)
        info:SetFont("ixSmallFont")
        info:SetText(L("vanguard_tickets_create_title"))
        info:SetContentAlignment(5)
        info:SetTextColor(color_white)
        info:SetExpensiveShadow(1, color_black)
        info:SizeToContents()
        info:SetTall(info:GetTall() + 16)
        info.Paint = function(this, width, height)
            surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", info), 160))
            surface.DrawRect(0, 0, width, height)
        end

        local titleEntry = container:Add("ixTextEntry")
        titleEntry:SetFont("ixMenuButtonFont")
        titleEntry:SetTall(ScreenScale(14))
        titleEntry:Dock(TOP)
        
        local info = container:Add("DLabel")
        info:SetFont("ixSmallFont")
        info:SetText(L("vanguard_tickets_create_description"))
        info:SetContentAlignment(5)
        info:SetTextColor(color_white)
        info:SetExpensiveShadow(1, color_black)
        info:SizeToContents()
        info:SetTall(info:GetTall() + 16)
        info:Dock(TOP)
        info:DockMargin(0, 8, 0, 8)
        info.Paint = function(this, width, height)
            surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", info), 160))
            surface.DrawRect(0, 0, width, height)
        end

        local descriptionEntry = container:Add("ixTextEntry")
        descriptionEntry:SetFont("ixMenuButtonFontSmall")
        descriptionEntry:SetTall(ScreenScale(14) * 4)
        descriptionEntry:SetMultiline(true)
        descriptionEntry:Dock(TOP)

        local button = container:Add("ixMenuButton")
        button:SetText(L("vanguard_tickets_create"))
        button:SetFont("ixMenuButtonFontSmall")
        button:SetContentAlignment(5)
        button:SizeToContents()
        button:Dock(TOP)
        button:DockMargin(0, 8, 0, 0)
        button.DoClick = function()
            local title = titleEntry:GetText()
            local description = descriptionEntry:GetText()

            net.Start("ixVanguardCreateTicket")
                net.WriteString(title)
                net.WriteString(description)
            net.SendToServer()
        
            self.bCreatingTicket = false
        end

        local button = container:Add("ixMenuButton")
        button:SetText(L("vanguard_tickets_cancel"))
        button:SetFont("ixMenuButtonFontSmall")
        button:SetContentAlignment(5)
        button:SizeToContents()
        button:Dock(TOP)
        button.DoClick = function()
            self.bCreatingTicket = false
            self:PopulateTickets(container)
        end
    else
        local info = container:Add("DLabel")
        info:SetFont("ixSmallFont")
        info:SetText(L("vanguard_tickets_no_active"))
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

        local button = container:Add("ixMenuButton")
        button:SetText(L("vanguard_tickets_create_new"))
        button:SetContentAlignment(5)
        button:SizeToContents()
        button:Dock(TOP)
        button.DoClick = function()
            self.bCreatingTicket = true
            self:PopulateTickets(container)
        end
    end
end