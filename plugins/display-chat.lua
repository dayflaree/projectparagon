local PLUGIN = PLUGIN

PLUGIN.name = "Display Chat Messages"
PLUGIN.description = "Displays what other characters saying above their heads (toggleable)."
PLUGIN.author = "Riggs"

ix.option.Add("chatDisplayEnabled", ix.type.bool, true, {
    category = "Chat Display"
})

ix.option.Add("chatDisplayLength", ix.type.number, 256, {
    category = "Chat Display",
    min = 10,
    max = 2048,
})

ix.option.Add("chatDisplayDurationPerSymbol", ix.type.number, 0.3, {
    category = "Chat Display",
    min = 0.01,
    max = 1,
    decimals = 2,
})

ix.option.Add("chatDisplayOwnDisplayEnabled", ix.type.bool, true, {
    category = "Chat Display",
})

ix.char.RegisterVar("staticAction", {
    field = "staticAction",
    fieldType = ix.type.text,
    default = "",
    // isLocal = true, // You need to network this, wtf?
    bNoDisplay = true,
})

ix.command.Add("StaticCharActionSet", {
    description = "@staticCharActionSet",
    arguments = ix.type.text,
    OnRun = function(self, ply, action)
        if ( #action > 255 ) then
            return "@staticCharActionSetTooLong"
        end

        local char = ply:GetCharacter()
        char:SetStaticAction(action)

        ply:NotifyLocalized("staticCharActionSetCallback")
    end,
})

ix.command.Add("StaticCharActionRemove", {
    description = "@staticCharActionRemove",
    OnRun = function(self, ply)
        local char = ply:GetCharacter()
        char:SetStaticAction(nil)

        ply:NotifyLocalized("staticCharActionRemoveCallback")
    end
})

ix.lang.AddTable("english", {
    optChatDisplayEnabled = "Enable chat display",
    optdChatDisplayEnabled = "Whether text should appear above characters' heads when they speak.",
    optChatDisplayLength = "Max chat display length",
    optdChatDisplayLength = "The maximum length of the chat display.",
    optChatDisplayDurationPerSymbol = "Display duration per text character",
    optdChatDisplayDurationPerSymbol = "How many seconds the chat should be displayed for per text character.",
    optChatDisplayOwnDisplayEnabled = "Display own messages",
    optdChatDisplayOwnDisplayEnabled = "Whether your own messages should appear above your head.",
    staticCharActionSet = "Set your character's static action",
    staticCharActionSetCallback = "You have set your character's static action.",
    staticCharActionRemove = "Remove your character's static action.",
    staticCharActionRemoveCallback = "You have removed your character's static action.",
    staticCharActionSetTooLong = "Your character's static action cannot be longer than 255 characters!",
})

function PLUGIN:PlayerLoadedCharacter(ply, character, lastChar)
    if ( lastChar ) then
        lastChar:SetStaticAction("")
    end
end

if ( SERVER ) then
    return
end

local stored = PLUGIN.chatDisplay or {}
PLUGIN.chatDisplay = stored

local standingOffset = Vector(0, 0, 0)
local crouchingOffset = Vector(0, 0, 0)
local boneOffset = Vector(0, 0, 15)
function PLUGIN:GetTypingIndicatorPosition(client)
    local head

    for i = 1, client:GetBoneCount() do
        local name = client:GetBoneName(i)

        if (string.find(name:lower(), "head")) then
            head = i
            break
        end
    end

    local position = head and client:GetBonePosition(head) or (client:Crouching() and crouchingOffset or standingOffset)
    return position + boneOffset
end

function PLUGIN:MessageReceived(ply, messageInfo)
    if ( IsValid(ply) and ix.option.Get("chatDisplayEnabled", false) ) then
        if ( ply == LocalPlayer() and !ix.option.Get("chatDisplayOwnDisplayEnabled", true) ) then return end

        if ( hook.Run("ShouldChatMessageDisplay", ply, messageInfo) != false) then
            local class = ix.chat.classes[messageInfo.chatType]
            local maxLen = ix.option.Get("chatDisplayLength")
            local text = messageInfo.text

            local textLen = string.utf8len(text)
            local duration = math.max(2, math.min(textLen, maxLen) * ix.option.Get("chatDisplayDurationPerSymbol"))

            stored[ply] = {
                text = textLen > maxLen and utf8.sub(text, 1, ix.option.Get("chatDisplayLength")) .. "..." or text,
                color = class and class.color or color_white,
                fadeTime = duration
            }
        end
    end
end

local whitelist = {
    ["me"] = true,
    ["ic"] = true,
    ["w"] = true,
    ["y"] = true,
    ["r"] = true,
    ["radio"] = true,
    ["roll"] = true,
}

function PLUGIN:ShouldChatMessageDisplay(ply, messageInfo)
    if ( messageInfo.anonymous ) then return false end

    if ( !whitelist[messageInfo.chatType] ) then return false end

    if ( LocalPlayer():EyePos():DistToSqr(ply:EyePos()) >= 300 * 300 ) then return false end
end

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    local plyPos = ply:EyePos()
    local scrW, scrH = ScrW(), ScrH()
    local halfWidth, halfHeight = scrW / 2, scrH / 2

    for k, v in player.Iterator() do
        if ( v == LocalPlayer() ) then continue end

        local char = v:GetCharacter()
        if ( !char ) then continue end

        local action = char:GetStaticAction()
        if ( !action or action == "" ) then continue end

        if ( stored[v] ) then continue end

        local vPos = hook.Run("GetTypingIndicatorPosition", v)
        local pos = vPos:ToScreen()

        local distSqr = plyPos:DistToSqr(vPos)
        if ( distSqr > 300 ^ 2 ) then continue end

        local camMult = (1 - math.Distance(halfWidth, halfHeight, pos.x, pos.y) / scrW * 1.5)
        local distanceMult = (1 - distSqr * 0.003 * 0.003) -- 0.003 == 1/300
        local alpha = 255 * camMult * distanceMult
        local col1, col2 = Color(175, 255, 150, alpha), Color(0, 0, 0, alpha)
        local font = "ixGenericFont"

        surface.SetFont(font)

        local fullH = select(2, surface.GetTextSize(action))
        local lines = ix.util.WrapText(action, scrW * 0.25, font)
        local offset = 4
        local curY = pos.y - ((fullH + offset) * #lines) / 2 

        for _, line in pairs(lines) do
            local width, height = surface.GetTextSize(line)

            draw.SimpleText(line, font, pos.x - width / 2, curY, col1, nil, nil, 1, col2)

            curY = curY + height + offset
        end
    end

    if ( ix.option.Get("chatDisplayEnabled", false) and stored and !table.IsEmpty(stored) ) then
        local toRem = {}

        for k, v in pairs(stored) do
            if ( IsValid(k) ) then
                local vPos = hook.Run("GetTypingIndicatorPosition", k)
                local pos = vPos:ToScreen()
                local distSqr = plyPos:DistToSqr(vPos)

                if ( distSqr <= 300 ^ 2 ) then
                    local camMult = (1 - math.Distance(halfWidth, halfHeight, pos.x, pos.y) / scrW * 1.5)
                    local distanceMult = (1 - distSqr * 0.003 * 0.003) -- 0.003 == 1/300
                    local alpha = 255 * camMult * distanceMult * math.min(v.fadeTime, 1)
                    local col1, col2 = ColorAlpha(v.color, alpha), Color(0, 0, 0, alpha)
                    local font = "ixGenericFont"

                    surface.SetFont(font)

                    local _, fullH = surface.GetTextSize(v.text)
                    local lines = ix.util.WrapText(v.text, scrW * 0.25, font)
                    local offset = 4
                    local curY = pos.y - ((fullH + offset) * #lines) / 2

                    for k1, v1 in pairs(lines) do
                        local w, h = surface.GetTextSize(v1)

                        draw.SimpleText(v1, font, pos.x - w / 2, curY, col1, nil, nil, 1, col2)

                        curY = curY + h + offset
                    end

                    v.fadeTime = v.fadeTime - FrameTime()

                    if ( v.fadeTime <= 0 ) then
                        table.insert(toRem, k)
                    end
                else
                    table.insert(toRem, k)
                end
            else
                table.insert(toRem, k)
            end
        end

        for k, v in pairs(toRem) do
            stored[v] = nil
        end
    end
end

-- Kumazaki Code, probably broken below

function PLUGIN:MessageReceived(ply, messageInfo)
    if ( IsValid(ply) and ix.option.Get("chatDisplayEnabled", false) ) then
        if ( ply == LocalPlayer() and !ix.option.Get("chatDisplayOwnDisplayEnabled", true) ) then return end

        if ( hook.Run("ShouldChatMessageDisplay", ply, messageInfo) != false) then
            local class = ix.chat.classes[messageInfo.chatType]
            local maxLen = ix.option.Get("chatDisplayLength")
            local text = messageInfo.text

            if messageInfo.chatType == "me" then
                -- /me messages
                text = "** " .. text .. " **"
            elseif messageInfo.chatType == "r" then
                -- /r messages
                text = "<:: " .. text .. " ::>"
            elseif messageInfo.chatType == "radio" then
                -- /radio messages
                text = "<:: " .. text .. " ::>"
            else
                -- normal chat messages
                text = "\" " .. text .. " \""
            end

            local textLen = string.utf8len(text)
            local duration = math.max(2, math.min(textLen, maxLen) * ix.option.Get("chatDisplayDurationPerSymbol"))

            stored[ply] = {
                text = textLen > maxLen and utf8.sub(text, 1, ix.option.Get("chatDisplayLength")) .. "..." or text,
                color = class and color_white,
                fadeTime = duration
            }
        end
    end
end
