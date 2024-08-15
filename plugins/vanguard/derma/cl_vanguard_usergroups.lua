/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

local backgroundColor = Color(0, 0, 0, 66)
function PANEL:Init()
    if ( IsValid(ix.gui.vanguardUsergroups) ) then
        ix.gui.vanguardUsergroups:Remove()
    end

    ix.gui.vanguardUsergroups = self

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

    buttons:SetWide(buttons.maxWidth)

    ix.gui.vanguardUsergroups = self
end

function PANEL:Populate()
    local buttons = self.buttons
    buttons:Clear()

    local scroller = buttons:Add("DScrollPanel")
    scroller:Dock(FILL)

    if ( IsValid(self.container) ) then
        self.container:Remove()
    end

    local usergroups = table.Copy(CAMI.GetUsergroups())
    for key, data in SortedPairsByMemberValue(usergroups, "Order") do
        local button = scroller:Add("ixVanguardMenuButton")
        button:Dock(TOP)
        button:SetText(data.Name)

        if ( data.Color ) then
            button:SetBackgroundColor(data.Color)
        end

        button:SizeToContents()
        button.DoClick = function(this)
            self:PopulateUsergroup(data)
        end
        button.DoRightClick = function(this)
            local menu = DermaMenu()

            menu:AddOption(L("vanguard_copy_to_clipboard"), function()
                SetClipboardText(data.Name)
            end)

            menu:AddOption(L("vanguard_usergroup_duplicate"), function()
                Derma_StringRequest("Helix", L("vanguard_usergroup_duplicate_name"), "", function(text)
                    if ( !text or text == "" ) then return end

                    net.Start("ixVanguardDuplicateUsergroup")
                        net.WriteString(data.Name)
                        net.WriteString(text)
                    net.SendToServer()
                end)
            end)

            menu:AddOption(L("vanguard_usergroup_delete"), function()
                Derma_Query(L("vanguard_usergroup_delete_confirm", data.Name), "Helix", L("yes"), function()
                    net.Start("ixVanguardDeleteUsergroup")
                        net.WriteString(data.Name)
                    net.SendToServer()
                end, L("no"))
            end)

            menu:Open()
        end

        buttons.maxWidth = math.max(buttons.maxWidth, button:GetWide())
    end

    local createNew = buttons:Add("ixVanguardMenuButton")
    createNew:Dock(BOTTOM)
    createNew:SetText(L("vanguard_usergroup_create_new"))
    createNew:SizeToContents()
    createNew.DoClick = function(this)
        Derma_StringRequest("Helix", L("vanguard_usergroup_create_new_name"), "", function(text)
            if ( !text or text == "" ) then return end

            Derma_Query(L("vanguard_usergroup_create_new_inherit"), "Helix", L("vanguard_usergroup_user"), function()
                net.Start("ixVanguardCreateUsergroup")
                    net.WriteString(text)
                    net.WriteString("user")
                net.SendToServer()
            end, L("vanguard_usergroup_admin"), function()
                net.Start("ixVanguardCreateUsergroup")
                    net.WriteString(text)
                    net.WriteString("admin")
                net.SendToServer()
            end, L("vanguard_usergroup_superadmin"), function()
                net.Start("ixVanguardCreateUsergroup")
                    net.WriteString(text)
                    net.WriteString("superadmin")
                net.SendToServer()
            end)
        end)
    end

    buttons.maxWidth = math.max(buttons.maxWidth, createNew:GetWide())

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)

        if ( #this:GetChildren() < 1 ) then
            derma.SkinFunc("DrawHelixCurved", width / 2, height / 2, width / 3.5)

            surface.SetFont("ixMenuButtonFontSmall")
            local text = L("vanguard_usergroup_select"):lower()
            local textWidth, textHeight = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width / 2 - textWidth / 2, height / 2 - textHeight / 2)
            surface.DrawText(text)
        end
    end

    self.container = container

    if ( ix.gui.vanguardUsergroupsLast ) then
        local usergroup = CAMI.GetUsergroup(ix.gui.vanguardUsergroupsLast)
        if ( usergroup ) then
            self:PopulateUsergroup(usergroup)
        end
    end
end

function PANEL:PopulateUsergroup(data)
    ix.gui.vanguardUsergroupsLast = data.Name

    self.container:Clear()

    if ( !data ) then return end
    if ( data.CAMI_Source != "Vanguard" ) then return end

    local scroller = self.container:Add("DScrollPanel")
    scroller:Dock(FILL)

    self.scroller = scroller

    local settings = scroller:Add("ixVanguardCategoryPanel")
    settings:Dock(TOP)
    settings:DockMargin(0, 0, 0, 8)
    settings:SetText(L("vanguard_usergroup_base_settings"))

    local defaultUsergroup = PLUGIN.defaultUsergroups["user"]
    if ( data.Name == "superadmin" or data.Inherits == "superadmin" ) then
        defaultUsergroup = PLUGIN.defaultUsergroups["superadmin"]
    elseif ( data.Name == "admin" or data.Inherits == "admin" ) then
        defaultUsergroup = PLUGIN.defaultUsergroups["admin"]
    end

    local usergroupDisplayName = settings:Add("ixVanguardSettingsRowString")
    usergroupDisplayName:SetText(L("vanguard_usergroup_displayname"))
    usergroupDisplayName:SetValue(data.DisplayName)
    usergroupDisplayName:Dock(TOP)
    usergroupDisplayName.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "DisplayName", value)
    end

    if ( usergroupDisplayName:GetValue() != defaultUsergroup.DisplayName ) then
        usergroupDisplayName:SetShowReset(true, "DisplayName", defaultUsergroup.DisplayName)
    end

    usergroupDisplayName.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(defaultUsergroup.DisplayName, true)

        self:UpdateUsergroup(data.Name, "DisplayName", defaultUsergroup.DisplayName)
    end

    local usergroupDisplayDescription = settings:Add("ixVanguardSettingsRowString")
    usergroupDisplayDescription:SetText(L("vanguard_usergroup_description_display"))
    usergroupDisplayDescription:SetValue(data.DisplayDescription)
    usergroupDisplayDescription:Dock(TOP)
    usergroupDisplayDescription.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "DisplayDescription", value)
    end

    if ( usergroupDisplayDescription:GetValue() != defaultUsergroup.DisplayDescription ) then
        usergroupDisplayDescription:SetShowReset(true, "DisplayDescription", defaultUsergroup.DisplayDescription)
    end

    usergroupDisplayDescription.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(defaultUsergroup.DisplayDescription, true)

        self:UpdateUsergroup(data.Name, "DisplayDescription", defaultUsergroup.DisplayDescription)
    end

    local usergroupDescription = settings:Add("ixVanguardSettingsRowString")
    usergroupDescription:SetText(L("vanguard_usergroup_description"))
    usergroupDescription:SetValue(data.Description)
    usergroupDescription:Dock(TOP)
    usergroupDescription.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "Description", value)
    end

    if ( usergroupDescription:GetValue() != defaultUsergroup.Description ) then
        usergroupDescription:SetShowReset(true, "Description", defaultUsergroup.Description)
    end

    local usergroupColor = settings:Add("ixVanguardSettingsRowColor")
    usergroupColor:SetText(L("vanguard_color"))
    usergroupColor:SetValue(data.Color or Color(200, 200, 200))
    usergroupColor:Dock(TOP)
    usergroupColor.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "Color", value)
    end

    if ( usergroupColor:GetValue() != defaultUsergroup.Color ) then
        usergroupColor:SetShowReset(true, "Color", defaultUsergroup.Color)
    end

    usergroupColor.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(defaultUsergroup.Color, true)

        self:UpdateUsergroup(data.Name, "Color", defaultUsergroup.Color)
    end

    local usergroupIcon = settings:Add("ixVanguardSettingsRowString")
    usergroupIcon:SetText(L("vanguard_icon"))
    usergroupIcon:SetValue(data.Icon or "icon16/user.png")
    usergroupIcon:Dock(TOP)
    usergroupIcon.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "Icon", value)
    end

    if ( usergroupIcon:GetValue() != defaultUsergroup.Icon ) then
        usergroupIcon:SetShowReset(true, "Icon", defaultUsergroup.Icon)
    end

    usergroupIcon.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(defaultUsergroup.Icon, true)

        self:UpdateUsergroup(data.Name, "Icon", defaultUsergroup.Icon)
    end

    local usergroupOrder = settings:Add("ixVanguardSettingsRowNumber")
    usergroupOrder:SetText(L("vanguard_order"))
    usergroupOrder:SetMin(0)
    usergroupOrder:SetMax(1000)
    usergroupOrder:SetValue(data.Order or 100)
    usergroupOrder:Dock(TOP)
    usergroupOrder.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "Order", value)
    end

    if ( usergroupOrder:GetValue() != defaultUsergroup.Order ) then
        usergroupOrder:SetShowReset(true, "Order", defaultUsergroup.Order)
    end

    usergroupOrder.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(defaultUsergroup.Order, true)

        self:UpdateUsergroup(data.Name, "Order", defaultUsergroup.Order)
    end

    local donatorPrivileges = settings:Add("ixVanguardSettingsRowBool")
    donatorPrivileges:SetText(L("vanguard_donator_privileges"))
    donatorPrivileges:SetValue(tobool(data.DonatorPrivileges))
    donatorPrivileges:Dock(TOP)
    donatorPrivileges.OnValueChanged = function(this, value)
        self:UpdateUsergroup(data.Name, "DonatorPrivileges", value == true and 1 or 0)
    end

    if ( donatorPrivileges:GetValue() != tobool(defaultUsergroup.DonatorPrivileges) ) then
        donatorPrivileges:SetShowReset(true, "DonatorPrivileges", tobool(defaultUsergroup.DonatorPrivileges))
    end

    donatorPrivileges.OnResetClicked = function(this)
        this:SetShowReset(false)
        this:SetValue(tobool(defaultUsergroup.DonatorPrivileges), true)

        self:UpdateUsergroup(data.Name, "DonatorPrivileges", tobool(defaultUsergroup.DonatorPrivileges) == true and 1 or 0)
    end

    settings:SizeToContents()
    
    if ( data.CanEdit != false ) then
        local searchEntry = scroller:Add("ixVanguardIconTextEntry")
        searchEntry:SetEnterAllowed(false)
        searchEntry:Dock(TOP)
        searchEntry.OnChange = function(entry)
            self:FilterPermissions(data, entry:GetText())
            ix.gui.vanguardUsergroupsLastPermissionFilter = entry:GetText()
        end

        if ( ix.gui.vanguardUsergroupsLastPermissionFilter ) then
            searchEntry:SetText(ix.gui.vanguardUsergroupsLastPermissionFilter)
        end

        local permissions = scroller:Add("ixVanguardCategoryPanel")
        permissions:Dock(TOP)
        permissions:DockMargin(0, 0, 0, 8)
        permissions:SetText(L("vanguard_permissions"))

        self.permissions = permissions

        self:FilterPermissions(data, ix.gui.vanguardUsergroupsLastPermissionFilter)
    end

    scroller:GetVBar():AnimateTo((ix.gui.vanguardUsergroupsLastScroll or 0), 0, 0, 0)
end

function PANEL:FilterPermissions(data, identifier)
    if ( !self.permissions ) then return end

    self.permissions:Clear()
    self.permissions:SetZPos(9999)

    local allowAll = self.permissions:Add("ixVanguardMenuButton")
    allowAll:Dock(TOP)
    allowAll:SetText(L("vanguard_allow_all"))
    allowAll:SetFont("ixMenuButtonFontSmall")
    allowAll:SizeToContents()
    allowAll.DoClick = function(this)
        Derma_Query(L("vanguard_permissions_allow_all_confirm", data.DisplayName), "Helix", L("yes"), function()
            for _, v in ipairs(self.permissions:GetChildren()) do
                if ( v.SetValue ) then
                    v:SetValue(true)
                end
            end

            net.Start("ixVanguardGrantAllPermissions")
                net.WriteString(data.Name)
            net.SendToServer()
        end, L("no"))
    end

    local disallowAll = self.permissions:Add("ixVanguardMenuButton")
    disallowAll:Dock(TOP)
    disallowAll:SetText(L("vanguard_disallow_all"))
    disallowAll:SetFont("ixMenuButtonFontSmall")
    disallowAll:SizeToContents()
    disallowAll.DoClick = function(this)
        Derma_Query(L("vanguard_permissions_disallow_all_confirm", data.DisplayName), "Helix", L("yes"), function()
            for _, v in ipairs(self.permissions:GetChildren()) do
                if ( v.SetValue ) then
                    v:SetValue(false)
                end
            end

            net.Start("ixVanguardRevokeAllPermissions")
                net.WriteString(data.Name)
            net.SendToServer()
        end, L("no"))
    end

    local resetAll = self.permissions:Add("ixVanguardMenuButton")
    resetAll:Dock(TOP)
    resetAll:SetText(L("vanguard_reset_all"))
    resetAll:SetFont("ixMenuButtonFontSmall")
    resetAll:SizeToContents()
    resetAll.DoClick = function(this)
        Derma_Query(L("vanguard_permissions_reset_all_confirm", data.DisplayName), "Helix", L("yes"), function()
            for _, v in ipairs(self.permissions:GetChildren()) do
                if ( v.SetValue ) then
                    v:SetValue(PLUGIN:GetDefaultPrivilege(data.Name, v.key))
                end
            end

            net.Start("ixVanguardResetAllPermissions")
                net.WriteString(data.Name)
            net.SendToServer()
        end, L("no"))
    end

    for key, value in SortedPairs(CAMI.GetPrivileges()) do
        if ( identifier and !ix.util.StringMatches(value.Name, identifier) ) then
            continue
        end

        local privilege = self.permissions:Add("ixVanguardSettingsRowBool")
        privilege:SetText(value.Name)
        privilege:SetValue(false)
        privilege:Dock(TOP)
        privilege.key = key

        local default = PLUGIN:GetDefaultPrivilege(data.Name, key)

        local permissions = PLUGIN.permissions or {}
        if ( permissions[key] ) then
            if ( table.HasValue(permissions[key], data.Name) ) then
                privilege:SetValue(true)
            end

            default = PLUGIN:GetDefaultPrivilege(data.Name, key)
        end

        if ( privilege:GetValue() != default ) then
            privilege:SetShowReset(true, value.Name, default)
        end

        privilege.OnValueChanged = function(this)
            local newValue = this:GetValue()

            this:SetShowReset(newValue != default, key, default)

            self:UpdateUsergroupPrivilege(data.Name, key, newValue)
        end

        privilege.OnResetClicked = function(this)
            this:SetShowReset(false)
            this:SetValue(default, true)

            self:UpdateUsergroupPrivilege(data.Name, key, default)
        end

        if ( !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Vanguard Usergroups - View", nil) ) then
            privilege:SetEnabled(false)
        end
    end

    self.permissions:SizeToContents()
end

function PANEL:UpdateUsergroup(name, key, value)
    net.Start("ixVanguardUpdateUsergroup")
        net.WriteString(name)
        net.WriteString(key)
        net.WriteType(value)
    net.SendToServer()
end

function PANEL:UpdateUsergroupPrivilege(name, key, value)
    net.Start("ixVanguardUpdateUsergroupPrivilege")
        net.WriteString(name)
        net.WriteString(key)
        net.WriteBool(value)
    net.SendToServer()
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardUsergroups", PANEL, "DPanel")

if ( IsValid(ix.gui.vanguardUsergroups) ) then
    ix.gui.vanguardUsergroups:Remove()
end