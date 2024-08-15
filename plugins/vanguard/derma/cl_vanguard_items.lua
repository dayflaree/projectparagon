/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local items = table.Copy(ix.item.list)

    table.sort(items, function(a, b)
        return L(a.name) < L(b.name)
    end)

    local categories = {}
    for k, v in pairs(items) do
        local category = L(v.category)
        if ( !categories[category] ) then
            categories[category] = {}
        end

        table.insert(categories[category], category)
    end

    table.sort(categories, function(a, b)
        return a < b
    end)

    self.items = items
    self.categories = categories

    self:Populate()

    ix.gui.vanguardItems = self
end

local stringMatches = ix.util.StringMatches // comment: gets called alot, so we localize it to save performance
function PANEL:Populate()
    local items = self.items
    local categories = self.categories

    local categoryPanel = self:Add("DPanel")
    categoryPanel:SetWide(180)
    categoryPanel:Dock(LEFT)
    categoryPanel:DockMargin(0, 0, 8, 0)
    categoryPanel.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 66)
        surface.DrawRect(0, 0, width, height)
    end

    local all = categoryPanel:Add("ixVanguardMenuButton")
    all:SetText(L("all"))
    all:SetFont("ixMenuButtonFontSmall")
    all:SetContentAlignment(5)
    all:SizeToContents()
    all:Dock(TOP)
    all.DoClick = function(this)
        self:PopulateItems()
    end

    local categoryScroller = categoryPanel:Add("DScrollPanel")
    categoryScroller:Dock(FILL)
    categoryScroller.VBar:SetWide(0)

    local maxWidth = 0
    for k, v in SortedPairs(categories) do
        local category = categoryScroller:Add("ixVanguardMenuButton")
        category:SetText(k)
        category:SetFont("ixMenuButtonFontSmall")
        category:SetContentAlignment(5)
        category:SizeToContents()
        category:Dock(TOP)
        category.DoClick = function(this)
            if ( stringMatches(k, "miscellaneous") ) then
                k = "misc"
            end

            self:PopulateItems(k)
        end

        maxWidth = math.max(maxWidth, category:GetWide())
    end

    categoryPanel:SetWide(maxWidth + 16)

    local searchEntry = self:Add("ixIconTextEntry")
    searchEntry:Dock(TOP)
    searchEntry:SetEnterAllowed(false)

    searchEntry.OnChange = function(this)
        self:PopulateItems(this:GetValue())
    end

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 66)
        surface.DrawRect(0, 0, width, height)
    end

    local itemScroller = container:Add("DScrollPanel")
    itemScroller:Dock(FILL)
    itemScroller.VBar:SetWide(0)

    self.itemList = itemScroller:Add("DIconLayout")
    self.itemList:Dock(TOP)
    self.itemList:InvalidateParent()

    timer.Simple(0.1, function()
        self:PopulateItems(ix.gui.vanguardItemsLastFilter or "")
    end)
end

function PANEL:PopulateItems(filter)
    self.itemList:Clear()

    local size = self.itemList:GetWide() / 8
    for k, v in pairs(self.items) do
        if ( filter and not ( stringMatches(v.uniqueID, filter) or stringMatches(v.name, filter) or stringMatches(v.category, filter) ) ) then
            continue
        end

        local button = self.itemList:Add("ixVanguardMenuButton")
        button:SetSize(size, size)
        button:SetText("")
        button.DoClick = function(this)
            ix.command.Send("CharGiveItem", LocalPlayer():SteamID(), v.uniqueID, 1)
        end
        button.DoRightClick = function(this)
            local menu = DermaMenu()

            menu:AddOption(L("vanguard_copy_to_clipboard"), function()
                SetClipboardText(v.uniqueID)
            end)

            menu:AddSpacer()

            local inventory = LocalPlayer():GetCharacter():GetInventory()
            local width, height = inventory:GetSize()
            local amount = 0

            for x = 1, width do
                for y = 1, height do
                    local item = inventory:GetItemAt(x, y)
                    if not ( item ) then
                        amount = amount + 1
                    end
                end
            end

            for i = 1, amount do
                menu:AddOption(L("vanguard_items_give", i), function()
                    ix.command.Send("CharGiveItem", LocalPlayer():SteamID(), v.uniqueID, i)
                end)
            end

            menu:Open()
        end

        button:SetHelixTooltip(function(tooltip)
            local name = tooltip:AddRow("name")
            name:SetText(v.name)
            name:SetBackgroundColor(ix.config.Get("color"))
            name:SizeToContents()

            local description = tooltip:AddRow("description")
            description:SetText(v.description)
            description:SizeToContents()
        end)

        local icon = button:Add("ixSpawnIcon")
        icon:Dock(FILL)
        icon:SetModel(v.model, v.skin)
        icon:SetMouseInputEnabled(false)

        local ent = icon:GetEntity()
        if ( !IsValid(ent) ) then
            continue
        end

        local material = ""
        if ( v.material ) then
            material = v.material
        elseif ( v.GetMaterial ) then
            material = v:GetMaterial()
        end

        ent:SetMaterial(material)
    end

    ix.gui.vanguardItemsLastFilter = filter
end

function PANEL:Paint()
end

vgui.Register("ixVanguardItems", PANEL, "DPanel")