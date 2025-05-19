-- Modified Tooltip Logic for Helix: Disable Item Tooltips, Enable Player Name Only

local animationTime = 1

-- panel meta
-- Prevent item tooltips from being created
-- Only allow tooltip creation for entities (like players)

do
    local PANEL = FindMetaTable("Panel")
    local ixChangeTooltip = ChangeTooltip
    local ixRemoveTooltip = RemoveTooltip
    local tooltip
    local lastHover

    function PANEL:SetHelixTooltip(callback)
        self:SetMouseInputEnabled(true)
        self.ixTooltip = callback
    end

    function ChangeTooltip(panel, ...)
        if (!panel.ixTooltip) then
            return ixChangeTooltip(panel, ...)
        end

        -- Block tooltip for items (they are panels with inventory icons, not entities)
        if (panel.GetClass and panel:GetClass():lower():find("item")) then
            return
        end

        RemoveTooltip()

        timer.Create("ixTooltip", 0.1, 1, function()
            if (!IsValid(panel) or lastHover != panel) then
                return
            end

            tooltip = vgui.Create("ixTooltip")
            panel.ixTooltip(tooltip)
            tooltip:SizeToContents()
        end)

        lastHover = panel
    end

    function RemoveTooltip()
        if (IsValid(tooltip)) then
            tooltip:Remove()
            tooltip = nil
        end

        timer.Remove("ixTooltip")
        lastHover = nil

        return ixRemoveTooltip()
    end
end

DEFINE_BASECLASS("DLabel")
local PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "maxWidth", "MaxWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "bNoMinimal", "MinimalHidden", FORCE_BOOL)

function PANEL:Init()
    self:SetFont("Font-Elements-ScreenScale10")
    self:SetText(L("unknown"))
    self:SetTextColor(color_white)
    self:SetTextInset(4, 0)
    self:SetContentAlignment(4)
    self:Dock(TOP)

    self.maxWidth = ScrW() * 0.5
    self.bNoMinimal = false
    self.bMinimal = false
end

function PANEL:IsMinimal()
    return self.bMinimal
end

function PANEL:SetImportant()
    self:SetFont("Font-Elements-ScreenScale10")
    self:SetExpensiveShadow(1, color_black)
    self:SetBackgroundColor(ix.config.Get("color"))
end

function PANEL:SetBackgroundColor(color)
    color = table.Copy(color)
    color.a = math.min(color.a or 255, 100)
    self.backgroundColor = color
end

function PANEL:SizeToContents()
    local contentWidth, contentHeight = self:GetContentSize()
    contentWidth = contentWidth + 4
    contentHeight = contentHeight + 4

    if (contentWidth > self.maxWidth) then
        self:SetWide(self.maxWidth - 4)
        self:SetTextInset(4, 0)
        self:SetWrap(true)
        self:SizeToContentsY()
    else
        self:SetSize(contentWidth, contentHeight)
    end
end

function PANEL:SizeToContentsY()
    BaseClass.SizeToContentsY(self)
    self:SetTall(self:GetTall() + 4)
end

function PANEL:PaintBackground(width, height)
    if (self.backgroundColor) then
        derma.SkinFunc("DrawImportantBackground", 0, 0, width, height, self.backgroundColor)
    end
end

function PANEL:Paint(width, height)
    self:PaintBackground(width, height)
end

vgui.Register("ixTooltipRow", PANEL, "DLabel")

-- Cursor position helper function for tooltip init
local function GetCursorPosition(self)
    local width, height = self:GetSize()
    local mouseX, mouseY = gui.MousePos()
    return math.Clamp(mouseX + self.mousePadding, 0, ScrW() - width), math.Clamp(mouseY, 0, ScrH() - height)
end

DEFINE_BASECLASS("Panel")
PANEL = {}

AccessorFunc(PANEL, "entity", "Entity")
AccessorFunc(PANEL, "mousePadding", "MousePadding", FORCE_NUMBER)
AccessorFunc(PANEL, "bDrawArrow", "DrawArrow", FORCE_BOOL)
AccessorFunc(PANEL, "arrowColor", "ArrowColor")
AccessorFunc(PANEL, "bHideArrowWhenRaised", "HideArrowWhenRaised", FORCE_BOOL)
AccessorFunc(PANEL, "bArrowFollowEntity", "ArrowFollowEntity", FORCE_BOOL)

function PANEL:Init()
    self.fraction = 0
    self.mousePadding = 16
    self.arrowColor = ix.config.Get("color")
    self.bHideArrowWhenRaised = true
    self.bArrowFollowEntity = true
    self.bMinimal = false

    self.lastX, self.lastY = GetCursorPosition(self)
    self.arrowX, self.arrowY = ScrW() * 0.5, ScrH() * 0.5

    self:SetAlpha(0)
    self:SetSize(0, 0)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(false)

    self:CreateAnimation(animationTime, {
        index = 1,
        target = {fraction = 1},
        easing = "outQuint",

        Think = function(animation, panel)
            panel:SetAlpha(panel.fraction * 255)
        end
    })
end

function PANEL:IsMinimal()
    return self.bMinimal
end

function PANEL:Add(...)
    local panel = BaseClass.Add(self, ...)
    panel:SetPaintedManually(true)
    return panel
end

function PANEL:AddRow(id)
    local panel = self:Add("ixTooltipRow")
    panel.id = id
    panel:SetZPos(#self:GetChildren() * 10)
    return panel
end

function PANEL:AddRowAfter(after, id)
    local panel = self:AddRow(id)
    after = self:GetRow(after)
    if (!IsValid(after)) then return panel end
    panel:SetZPos(after:GetZPos() + 1)
    return panel
end

function PANEL:SetEntity(entity)
    if (!IsValid(entity)) then
        self.bEntity = false
        return
    end

    -- Player tooltip: show name only
    if (entity:IsPlayer()) then
        local character = entity:GetCharacter()
        if (character) then
            local nameRow = self:AddRow("name")
            nameRow:SetText(character:GetName())
            nameRow:SetImportant()
            nameRow:SizeToContents()
        end
    end

    self:SizeToContents()
    self.entity = entity
    self.bEntity = true
end

vgui.Register("ixTooltip", PANEL, "Panel")
