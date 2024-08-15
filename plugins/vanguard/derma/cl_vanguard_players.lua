/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

local backgroundColor = Color(0, 0, 0, 66)
function PANEL:Init()
    self.page = 0

    self:Dock(FILL)

    local searchEntry = self:Add("ixIconTextEntry")
    searchEntry:Dock(TOP)
    searchEntry:SetEnterAllowed(false)

    searchEntry.OnChange = function(this)
        self:FilterPlayers(this:GetValue())
    end

    self.searchEntry = searchEntry

    local playersList = self:Add("DScrollPanel")
    playersList:Dock(FILL)
    playersList:DockMargin(0, 8, 0, 0)
    playersList.Paint = function(this, width, height)
        if ( #self.playersList:GetCanvas():GetChildren() == 0 ) then
            derma.SkinFunc("DrawHelixCurved", width / 2, height / 2, width * 0.25)

            surface.SetFont("ixIntroSubtitleFont")
            local text = L("noPlayers"):lower()
            local textWidth, textHeight = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width / 2 - textWidth / 2, height / 2 - textHeight / 2)
            surface.DrawText(text)
        end
    end

    self.playersList = playersList

    self:PopulatePlayers()

    ix.gui.vanguardPlayers = self
end

function PANEL:FilterPlayers(search)
    self:PopulatePlayers(search)
end

local stringMatches = ix.util.StringMatches
function PANEL:PopulatePlayers(filter)
    self.playersList:GetCanvas():Clear()

    self.categories = {}

    local players = {}
    for k, v in player.Iterator() do
        local usergroup = CAMI.GetUsergroup(v:GetUserGroup() or "user")
        players[v:EntIndex()] = {v, usergroup, usergroup.Order}
    end

    for index, data in SortedPairsByMemberValue(players, 3, true) do
        local ply = data[1]
        if ( !IsValid(ply) ) then continue end

        local usergroup = data[2]

        // I LOVE FILTERS SO MUCH - riggs
        if ( filter and !( stringMatches(ply:SteamName(), filter) or stringMatches(usergroup.Name, filter) or stringMatches(ply:SteamID(), filter) or stringMatches(ply:SteamID64(), filter) or stringMatches(ply:Name(), filter) ) ) then
            continue
        end

        local category = self.categories[usergroup]
        if not ( self.categories[usergroup] ) then
            category = self.playersList:Add("ixCategoryPanel")
            category:Dock(TOP)
            category:DockMargin(0, 0, 0, 16)
            category:SetTall(32)
            category:SetText(usergroup.DisplayName or usergroup.Name)
            category:SetColor(usergroup.Color)
            category:SetMouseInputEnabled(true)

            self.categories[usergroup] = category
        end

        local panel = category:Add("DPanel")
        panel:Dock(TOP)
        panel:SetTall(64)
        panel:SetMouseInputEnabled(true)

        panel.Think = function(this)
            if ( !IsValid(ply) ) then
                this:Remove()
            end
        end

        panel.OnMousePressed = function(this, code)
            local menu = DermaMenu()

            menu:AddOption(L("viewProfile"), function()
                ply:ShowProfile()
            end)

            menu:AddOption(L("copySteamID"), function()
                SetClipboardText(ply:IsBot() and ply:EntIndex() or ply:SteamID())
            end)

            hook.Run("PopulateScoreboardPlayerMenu", ply, menu)

            menu:Open()
        end

        panel.Paint = function(this, width, height)
            surface.SetDrawColor(backgroundColor)
            surface.DrawRect(0, 0, width, height)
        end

        local avatar = panel:Add("AvatarImage")
        avatar:Dock(LEFT)
        avatar:SetSize(64, 64)
        avatar:SetPlayer(ply, 64)

        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(4, 4, 0, 0)
        label:SetFont("ixGenericFont")
        label:SetText(ply:SteamName() .. " (" .. ply:GetName() .. ") (" .. ply:SteamID64() .. ")")
        label:SetContentAlignment(4)
        label:SetTextColor(color_white)
        label:SetMouseInputEnabled(false)
        label.Think = function(this)
            if ( !IsValid(ply) ) then
                return
            end

            if ( ( this.nextUpdate or 0 ) < CurTime() ) then
                this:SetText(ply:SteamName() .. " (" .. ply:GetName() .. ") (" .. ply:SteamID64() .. ")")
                this.nextUpdate = CurTime() + 1
            end
        end

        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:DockMargin(5, 0, 0, 0)
        description:SetFont("ixSmallFont")
        description:SetText(usergroup.DisplayDescription or usergroup.Description or "")
        description:SetContentAlignment(4)
        description:SetTextColor(color_white)
        description:SetMouseInputEnabled(false)
        description.Think = function(this)
            if ( !IsValid(ply) ) then
                return
            end

            if ( ( this.nextUpdate or 0 ) < CurTime() ) then
                usergroup = CAMI.GetUsergroup(ply:GetUserGroup() or "user")

                this:SetText(usergroup.DisplayDescription or usergroup.Description or "")
                this.nextUpdate = CurTime() + 1
            end
        end

        category:SizeToContents()
    end
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardPlayers", PANEL, "DPanel")