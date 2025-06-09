ix.bar = ix.bar or {}
ix.bar.list = ix.bar.list or {}
ix.bar.delta = ix.bar.delta or {}
ix.bar.actionText = ix.bar.actionText or ""
ix.bar.actionStart = ix.bar.actionStart or 0
ix.bar.actionEnd = ix.bar.actionEnd or 0
ix.bar.totalHeight = ix.bar.totalHeight or 0

BAR_HEIGHT = 10

function ix.bar.Get(identifier)
    for i, v in ipairs(ix.bar.list) do
        if (v.identifier == identifier) then
            v.index = i
            return v
        end
    end
end

function ix.bar.Remove(identifier)
    local barData = ix.bar.Get(identifier)

    if (barData) then
        table.remove(ix.bar.list, barData.index)

        for i, v in ipairs(ix.bar.list) do
            v.index = i
        end

        if (IsValid(ix.gui.bars) and IsValid(barData.panel)) then
            ix.gui.bars:RemoveBar(barData.panel)
        end
    end
end

function ix.bar.Add(getValue, color, priority, identifier)
    if (identifier) then
        ix.bar.Remove(identifier)
    end

    local index = #ix.bar.list + 1

    color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255))
    priority = priority or index

    local barData = {
        index = index,
        color = color,
        priority = priority,
        GetValue = getValue,
        identifier = identifier,
    }
    ix.bar.list[index] = barData

    if (IsValid(ix.gui.bars)) then
        barData.panel = ix.gui.bars:AddBar(index, color, priority)
    end

    return priority
end

local ACTION_BAR_TOTAL_TICKS = 20
local ACTION_BAR_TICK_WIDTH, ACTION_BAR_TICK_HEIGHT = 8, 14
local ACTION_BAR_TICK_SPACING = 0
local ACTION_BAR_FRAME_PADDING = 3
local ACTION_BAR_TICK_MATERIAL = Material("projectparagon/gfx/BlinkMeter.png", "smooth")

local TEXT_COLOR = Color(240, 240, 240)
local SHADOW_COLOR = Color(20, 20, 20, 200)

function ix.bar.DrawAction()
    local startTm, finishTm = ix.bar.actionStart, ix.bar.actionEnd
    local curTime = CurTime()
    local scrW, scrH = ScrW(), ScrH()

    if (finishTm > curTime and startTm < finishTm) then
        local duration = finishTm - startTm
        local elapsed = curTime - startTm
        local progress = math.Clamp(elapsed / duration, 0, 1)
        local remainingFraction = 1 - progress
        local activeTicks = math.Clamp(math.Round(remainingFraction * ACTION_BAR_TOTAL_TICKS), 0, ACTION_BAR_TOTAL_TICKS)
        local alpha = 255

        if (activeTicks > 0 or progress < 1) then
            local totalBarWidth = ACTION_BAR_TOTAL_TICKS * ACTION_BAR_TICK_WIDTH + math.max(0, ACTION_BAR_TOTAL_TICKS - 1) * ACTION_BAR_TICK_SPACING
            local barHeightWithPadding = ACTION_BAR_TICK_HEIGHT + ACTION_BAR_FRAME_PADDING * 2
            local barContainerWidth = totalBarWidth + ACTION_BAR_FRAME_PADDING * 2
            local x = (scrW - barContainerWidth) / 2
            local y = (scrH * 0.725) - (barHeightWithPadding / 2)

            surface.SetDrawColor(35, 35, 35, 200)
            surface.DrawRect(x, y, barContainerWidth, barHeightWithPadding)
            surface.SetDrawColor(0, 0, 0, 220)
            surface.DrawOutlinedRect(x, y, barContainerWidth, barHeightWithPadding)

            local ticksStartX = x + ACTION_BAR_FRAME_PADDING
            local ticksY = y + ACTION_BAR_FRAME_PADDING

            surface.SetMaterial(ACTION_BAR_TICK_MATERIAL)
            surface.SetDrawColor(255, 255, 255, alpha)

            for i = 1, activeTicks do
                local xPos = ticksStartX + (i - 1) * (ACTION_BAR_TICK_WIDTH + ACTION_BAR_TICK_SPACING)
                surface.DrawTexturedRect(xPos, ticksY, ACTION_BAR_TICK_WIDTH, ACTION_BAR_TICK_HEIGHT)
            end

            local text = ix.bar.actionText
            if (text and text ~= "") then
                local textX = x + barContainerWidth / 2
                local textY = y - 24

                draw.SimpleText(text, "ixMediumFont", textX + 2, textY + 2, SHADOW_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(text, "ixMediumFont", textX, textY, TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    else
        if (ix.bar.actionEnd ~= 0 and curTime >= ix.bar.actionEnd) then
            ix.bar.actionStart = 0
            ix.bar.actionEnd = 0
            ix.bar.actionText = ""
        end
    end
end

do
    if not ix.bar.Get("health") then
        ix.bar.Add(function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return 0 end
            return math.max(ply:Health() / ply:GetMaxHealth(), 0)
        end, Color(200, 50, 40), 100, "health")
    end

    if not ix.bar.Get("armor") then
        ix.bar.Add(function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return 0 end
            return math.min(ply:Armor() / 100, 1)
        end, Color(30, 70, 180), 99, "armor")
    end
end

net.Receive("ixActionBar", function()
    local start = net.ReadFloat()
    local finish = net.ReadFloat()
    local text = net.ReadString()

    if (text:sub(1, 1) == "@") then
        text = L2(text:sub(2)) or text
    end

    ix.bar.actionStart = start
    ix.bar.actionEnd = finish
    ix.bar.actionText = text:utf8upper()
end)

net.Receive("ixActionBarReset", function()
    ix.bar.actionStart = 0
    ix.bar.actionEnd = 0
    ix.bar.actionText = ""
end)