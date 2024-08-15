/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local PANEL = {}

local soundsData = {}
local backgroundColor = Color(0, 0, 0, 66)
function PANEL:Init()
    if ( IsValid(ix.gui.vanguardSounds) ) then
        ix.gui.vanguardSounds:Remove()
    end

    ix.gui.vanguardSounds = self

    self:Dock(FILL)

    local container = self:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(this, width, height)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, width, height)
    end

    local buttons = self:Add("DPanel")
    buttons:Dock(BOTTOM)
    buttons:DockMargin(0, 8, 0, 0)
    buttons.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 66)
        surface.DrawRect(0, 0, width, height)
    end

    self.container = container
    self.buttons = buttons

    self:Populate()

    ix.gui.vanguardSounds = self
end

function PANEL:PlaySound(directory)
    surface.PlaySound(directory)
end

function PANEL:SearchSounds(node, directory)
    local files, folders = file.Find(directory .. "*", "GAME")

    for _, v in ipairs(folders) do
        local folder = node:AddNode(v)
        folder:SetIcon("icon16/folder.png")
        folder.Label:SetExpensiveShadow(1, color_black)
        folder.directory = string.sub(directory, 7) .. v
        folder.generated = false
        folder.DoClick = function()
            if ( folder.generated ) then return end
            folder.generated = true

            self:SearchSounds(folder, directory .. v .. "/")
        end

        folder.SetExpandedOld = folder.SetExpanded
        folder.SetExpanded = function(this, b, bSurpressAnimation)
            this:SetExpandedOld(b, bSurpressAnimation)
            soundsData[#soundsData + 1] = {v, folder.directory, b}
        end
    end

    for _, v in ipairs(files) do
        if ( v:find("%.wav") or v:find("%.mp3") or v:find("%.ogg") ) then
            local sound = node:AddNode(v)
            sound:SetIcon("icon16/sound.png")
            sound.Label:SetExpensiveShadow(1, color_black)
            sound.directory = string.sub(directory, 7) .. v
            sound.DoClick = function()
                self:PlaySound(directory .. v)
            end
            sound.OnMousePressed = function(this, code)
                if ( code == MOUSE_RIGHT ) then
                    local menu = DermaMenu()
                    menu:AddOption(L("vanguard_copy_to_clipboard"), function()
                        SetClipboardText(directory .. v)
                    end)
                    menu:Open()
                end
            end
            sound.OnKeyCodePressed = function(this, code)
                if ( code == KEY_SPACE ) then
                    self:PlaySound(directory .. v)
                end
            end
        end
    end
end

function PANEL:Populate()
    local container = self.container
    local buttons = self.buttons

    local tree = container:Add("DTree")
    tree:SetPaintBackground(false)
    tree:Dock(FILL)

    self.tree = tree

    self:SearchSounds(tree, "sound/")

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Play sound")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/sound.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(LEFT)
    button.DoClick = function()
        local selected = tree:GetSelectedItem()
        if ( IsValid(selected) and ( selected.directory:find("%.wav") or selected.directory:find("%.mp3") or selected.directory:find("%.ogg") ) ) then
            self:PlaySound(selected.directory)
        end
    end

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Copy path")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/page_copy.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(LEFT)
    button.DoClick = function()
        local selected = tree:GetSelectedItem()
        if ( IsValid(selected) ) then
            SetClipboardText(selected.directory)
        end
    end

    local button = buttons:Add("ixVanguardMenuButton")
    button:SetText("Refresh")
    button:SetFont("ixMenuButtonFontSmall")
    button:SetIcon("icon16/arrow_refresh.png")
    button:SetContentAlignment(5)
    button:SizeToContents()
    button:Dock(LEFT)
    button.DoClick = function()
        self.tree:Clear()
        self:SearchSounds(self.tree, "sound/")
    end

    buttons:SizeToChildren(false, true)
end

function PANEL:Paint(width, height)
end

vgui.Register("ixVanguardSounds", PANEL, "DPanel")

if ( IsValid(ix.gui.vanguardSounds) ) then
    ix.gui.vanguardSounds:Remove()
end