/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local function AddTab(tabs, name, panel, callback)
    tabs[name] = {
        Create = function(info, container)
            local addedpanel = container:Add(panel)

            if ( callback ) then
                callback(info, container, addedpanel)
            end
        end
    }
end

local CREDITS = {
    {"Riggs", "76561197963057641", {"vanguard_credits_lead_developer", "vanguard_credits_designer"}},
    {"eon (bloodycop)", "76561198373309941", {"vanguard_credits_assistant_developer"}}
}

local MISC = {
    {"Aspect™", "Inspiration of Vanguard by creating Squadron, his own administration tool for his community."},
    {"Minerva Servers", "The community that Vanguard is developed for."},
    {"Helix", "The framework that powers Vanguard."},
}

local backgroundColor = Color(0, 0, 0, 66)
local url = "https://minerva-servers.com"
local padding = 32
local versionCurrent = PLUGIN.version
local versionLatest = ""

local function FetchVersion()
    http.Fetch("https://minerva-servers.com/vanguard/version.txt", function(body)
        versionLatest = body

        if ( versionCurrent != versionLatest ) then
            MsgC(Color(255, 0, 0), "[Vanguard] Your version is outdated! Current version: " .. versionLatest .. "\n")
        end
    end)
end

hook.Add("InitPostEntity", "VanguardFetchVersion", FetchVersion)
hook.Add("OnReloaded", "VanguardFetchVersion", FetchVersion)

function PLUGIN:CreateVanguardMenuButtons(tabs)
    local ply = LocalPlayer()
    tabs["about"] = {
        Create = function(info, container)
            if ( versionCurrent != versionLatest ) then
                local info = container:Add("DLabel")
                info:SetFont("ixSmallFont")
                info:SetText(L("vanguard_outdated_version", versionCurrent, versionLatest))
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

            local scroller = container:Add("DScrollPanel")
            scroller:Dock(FILL)

            local logo = scroller:Add("DPanel")
            logo:Dock(TOP)
            logo:SetTall(ScrH() / 1.5)
            logo.Paint = function(this, width, height)
                derma.SkinFunc("DrawHelixCurved", width / 2, height / 2, width / 5)

                surface.SetFont("ixIntroSubtitleFont")
                local text = L("vanguard"):lower()
                local textWidth, textHeight = surface.GetTextSize(text)

                local x = width / 2 - textWidth / 2
                local y = height / 2 - textHeight / 2

                surface.SetTextColor(color_white)
                surface.SetTextPos(x, y)
                surface.DrawText(text)

                local description = L("vanguard_description_short"):lower()
                surface.SetFont("ixMenuButtonLabelFont")
                local descWidth, descHeight = surface.GetTextSize(description)

                x = width / 2 - descWidth / 2

                surface.SetTextPos(x, y + textHeight + 4)
                surface.DrawText(description)
            end

            local link = scroller:Add("DLabel", self)
            link:SetFont("ixMenuMiniFont")
            link:SetTextColor(Color(200, 200, 200, 255))
            link:SetText(url)
            link:SetContentAlignment(5)
            link:SizeToContents()
            link:SetMouseInputEnabled(true)
            link:SetCursor("hand")
            link:Dock(TOP)
            link.OnMousePressed = function()
                gui.OpenURL(url)
            end

            local description = scroller:Add("DLabel")
            description:SetText(L("vanguard_description"))
            description:SetTextColor(color_white)
            description:SetFont("ixMenuButtonLabelFont")
            description:SetExpensiveShadow(1, color_black)
            description:SetWrap(true)
            description:SetAutoStretchVertical(true)
            description:Dock(TOP)
            description:DockMargin(0, 8, 0, 0)

            for _, v in ipairs(CREDITS) do
                local row = scroller:Add("ixCreditsRow")
                row:SetName(v[1])
                row:SetAvatar(v[2])
                row:SetTags(v[3])
                row:SizeToContents()
            end

            local specials = scroller:Add("ixLabel")
            specials:SetFont("ixMenuButtonFont")
            specials:SetText(L("creditSpecial"):utf8upper())
            specials:SetTextColor(ix.config.Get("color"))
            specials:SetDropShadow(1)
            specials:SetKerning(16)
            specials:SetContentAlignment(5)
            specials:DockMargin(0, padding * 2, 0, padding)
            specials:Dock(TOP)
            specials:SizeToContents()

            for _, v in ipairs(MISC) do
                local title = scroller:Add("DLabel")
                title:SetFont("ixMenuButtonFontThick")
                title:SetText(v[1])
                title:SetContentAlignment(5)
                title:SizeToContents()
                title:DockMargin(0, padding, 0, 0)
                title:Dock(TOP)

                local description = scroller:Add("DLabel")
                description:SetFont("ixSmallTitleFont")
                description:SetText(v[2])
                description:SetContentAlignment(5)
                description:SizeToContents()
                description:Dock(TOP)
            end
        end
    }

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Items", nil) ) then
        AddTab(tabs, "vanguard_items", "ixVanguardItems")
    end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Logs - View", nil) ) then
        AddTab(tabs, "vanguard_logs", "ixVanguardLogs")
    end

    AddTab(tabs, "vanguard_players", "ixVanguardPlayers")

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Blacklist - View", nil) ) then
        AddTab(tabs, "vanguard_props", "ixVanguardProps")
    end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tickets - View", nil) ) then
        AddTab(tabs, "vanguard_tickets", "ixVanguardTickets")
    end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tools - View", nil) ) then
        AddTab(tabs, "vanguard_tools", "ixVanguardTools")
    end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - View", nil) ) then
        AddTab(tabs, "vanguard_usergroups", "ixVanguardUsergroups")
    end
    
    if ( CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Config", nil) ) then
        tabs["config"] = {
            Create = function(info, container)
                container.panel = container:Add("ixConfigManager")
            end,

            OnSelected = function(info, container)
                container.panel.searchEntry:RequestFocus()
            end,

            Sections = {
                plugins = {
                    Create = function(info, container)
                        ix.gui.pluginManager = container:Add("ixPluginManager")
                    end,

                    OnSelected = function(info, container)
                        ix.gui.pluginManager.searchEntry:RequestFocus()
                    end
                }
            }
        }
    end
end

function PLUGIN:PopulateHelpMenu(tabs)
    tabs["tickets"] = function(container)
        container:DisableScrolling()
        container:DockPadding(8, 8, 8, 8)

        local bPopulated = false
        container.Populate = function(this, width, height)
            if ( bPopulated ) then return end
            bPopulated = true

            self:PopulateTickets(this, width, height)
        end

        local oldPaint = container.Paint
        container.Paint = function(this, width, height)
            oldPaint(this, width, height)

            this:Populate(width, height)
        end
    end
end

function PLUGIN:PopulateScoreboardPlayerMenu(target, menu)
    if ( !IsValid(target) ) then return end
    if ( !LocalPlayer():IsAdmin() ) then return end

    local id = target:IsBot() and target:Nick() or target:SteamID()

    menu:AddSpacer()

    // Goto
    self:AddMenuOption(menu, "Goto", "icon16/arrow_up.png", function()
        RunConsoleCommand("ix", "PlyGoto", id)
    end)

    // Bring
    self:AddMenuOption(menu, "Bring", "icon16/arrow_down.png", function()
        RunConsoleCommand("ix", "PlyBring", id)
    end)

    menu:AddSpacer()

    // Teleport to player
    local players = {}
    for k, v in player.Iterator() do
        if ( v == target ) then continue end

        players[v:Nick()] = function()
            RunConsoleCommand("ix", "PlyTeleportTo", id, v:IsBot() and v:Nick() or v:SteamID())
        end
    end

    self:AddMenuOptions(menu, "Teleport to", "icon16/arrow_in.png", players)

    // Teleport to area
    local areas = {}
    for k, v in pairs(ix.area.stored) do
        areas[k] = function()
            RunConsoleCommand("ix", "PlyTeleportToArea", id, k)
        end
    end

    self:AddMenuOptions(menu, "Teleport to Area", "icon16/world_go.png", areas)

    menu:AddSpacer()

    // Respawn
    self:AddMenuOption(menu, "Respawn", "icon16/arrow_refresh.png", function()
        RunConsoleCommand("ix", "PlyRespawn", id)
    end)

    // Respawn, and then bring
    self:AddMenuOption(menu, "Respawn and Bring", "icon16/arrow_refresh.png", function()
        RunConsoleCommand("ix", "PlyRespawn", id)

        timer.Simple(0.5, function()
            RunConsoleCommand("ix", "PlyBring", id)
        end)
    end)

    // Kick
    self:AddMenuOption(menu, "Kick", "icon16/disconnect.png", function()
        Derma_StringRequest("Kick Player", "Enter a reason for kicking this player.", "", function(text)
            RunConsoleCommand("ix", "PlyKick", id, text)
        end)
    end)

    // Ban
    self:AddMenuOption(menu, "Ban", "icon16/delete.png", function()
        Derma_StringRequest("Ban Player", "Enter a reason for banning this player.", "", function(text)
            Derma_StringRequest("Ban Player", "Enter a duration for the ban.", "", function(text2)
                RunConsoleCommand("ix", "PlyBan", id, text, text2)
            end)
        end)
    end)

    // Spectate options
    self:AddMenuOptions(menu, "Spectate", "icon16/eye.png", {
        ["First Person"] = function()
            RunConsoleCommand("ix", "PlySpectate", id, "1")
        end,
        ["Third Person"] = function()
            RunConsoleCommand("ix", "PlySpectate", id, "0")
        end
    })

    menu:AddSpacer()

    // Whitelist factions
    local options = {}
    for k, v in SortedPairsByMemberValue(ix.faction.indices, "sortOrder") do
        if ( v.isDefault ) then continue end
        if ( target:HasWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyWhitelist", id, v.uniqueID)
        end
    end

    options[L("vanguard_whitelist_all")] = function()
        RunConsoleCommand("ix", "PlyWhitelistAll", id)
    end

    self:AddMenuOptions(menu, "Whitelist Faction", "icon16/group_add.png", options)

    // Unwhitelist factions
    options = {}
    for k, v in SortedPairsByMemberValue(ix.faction.indices, "sortOrder") do
        if ( v.isDefault ) then continue end
        if ( !target:HasWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyUnwhitelist", id, v.uniqueID)
        end
    end

    options[L("vanguard_unwhitelist_all")] = function()
        RunConsoleCommand("ix", "PlyUnwhitelistAll", id)
    end

    self:AddMenuOptions(menu, "Unwhitelist Faction", "icon16/group_delete.png", options)

    // Transfer factions
    options = {}
    for k, v in SortedPairsByMemberValue(ix.faction.indices, "sortOrder") do
        if ( !target:HasWhitelist(v.index) ) then continue end
        if ( !target:GetCharacter() ) then continue end
        if ( target:GetCharacter():GetFaction() == v.index ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyTransfer", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Transfer Faction", "icon16/group_go.png", options)

    menu:AddSpacer()

    // Whitelist classes
    options = {}
    for k, v in SortedPairsByMemberValue(ix.class.list, "sortOrder") do
        if ( target:HasClassWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyClassWhitelist", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Whitelist Class", "icon16/user_add.png", options)

    // Unwhitelist classes
    options = {}
    for k, v in SortedPairsByMemberValue(ix.class.list, "sortOrder") do
        if ( !target:HasClassWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyUnClassWhitelist", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Unwhitelist Class", "icon16/user_delete.png", options)

    // Transfer classes
    options = {}
    for k, v in SortedPairsByMemberValue(ix.class.list, "sortOrder") do
        if ( !target:HasClassWhitelist(v.index) ) then continue end
        if ( !target:GetCharacter() ) then continue end
        if ( target:GetCharacter():GetClass() == v.index ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "CharSetClass", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Transfer Class", "icon16/user_go.png", options)

    menu:AddSpacer()

    // Whitelist ranks
    options = {}
    for k, v in SortedPairsByMemberValue(ix.rank.list, "sortOrder") do
        if ( target:HasRankWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyRankWhitelist", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Whitelist Rank", "icon16/user_add.png", options)

    // Unwhitelist ranks
    options = {}
    for k, v in SortedPairsByMemberValue(ix.rank.list, "sortOrder") do
        if ( !target:HasRankWhitelist(v.index) ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "PlyUnRankWhitelist", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Unwhitelist Rank", "icon16/user_delete.png", options)

    // Transfer ranks
    options = {}
    for k, v in SortedPairsByMemberValue(ix.rank.list, "sortOrder") do
        if ( !target:HasRankWhitelist(v.index) ) then continue end
        if ( !target:GetCharacter() ) then continue end
        if ( target:GetCharacter():GetRank() == v.index ) then continue end

        options[L(v.name)] = function()
            RunConsoleCommand("ix", "CharSetRank", id, v.uniqueID)
        end
    end

    self:AddMenuOptions(menu, "Transfer Rank", "icon16/user_go.png", options)

    menu:AddSpacer()
end

function PLUGIN:LoadFonts()
    surface.CreateFont("VanguardChatFont", {
        font = "Cambria",
        size = 18,
        weight = 800,
        antialias = true,
        shadow = true,
        italic = true
    })
end

local observerLight = false
local nextObserverLight = 0
function PLUGIN:Think()
    local ply = LocalPlayer()
    if ( !IsValid(ply) or !ply:Alive() ) then return end

    if ( nextObserverLight > CurTime() ) then return end

    if ( input.IsKeyDown(KEY_F) and ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle() and CAMI.PlayerHasAccess(ply, "Helix - Observer", nil) and !vgui.CursorVisible() ) then
        observerLight = !observerLight
        nextObserverLight = CurTime() + 1

        LocalPlayer():EmitSound("buttons/lever7.wav", 60, observerLight and 150 or 100)
    end
end

local observerProjectedTexture
function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    if ( !IsValid(ply) or !ply:Alive() ) then return end

    if ( ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle() and CAMI.PlayerHasAccess(ply, "Helix - Observer", nil) and observerLight ) then
        if ( IsValid(observerProjectedTexture) ) then
            observerProjectedTexture:SetPos(ply:EyePos())
            observerProjectedTexture:SetAngles(ply:EyeAngles())
            observerProjectedTexture:Update()
        else
            observerProjectedTexture = ProjectedTexture()
            observerProjectedTexture:SetTexture("effects/flashlight001")
            observerProjectedTexture:SetFarZ(ix.option.Get("observerLightRange", 8192))
            observerProjectedTexture:SetEnableShadows(false)
            observerProjectedTexture:SetColor(ix.option.Get("observerLightColor", Color(255, 255, 255)))
            observerProjectedTexture:SetBrightness(ix.option.Get("observerLightBrightness", 1))
            observerProjectedTexture:SetFOV(ix.option.Get("observerLightFOV", 170))
            observerProjectedTexture:SetPos(ply:EyePos())
            observerProjectedTexture:SetAngles(ply:EyeAngles())
            observerProjectedTexture:Update()
        end
    else
        if ( observerProjectedTexture ) then
            observerProjectedTexture:Remove()
            observerProjectedTexture = nil
        end
    end
end