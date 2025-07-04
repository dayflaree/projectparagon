local PLUGIN = PLUGIN

local function DrawTextBackground(x, y, text, font, backgroundColor, padding)
    font = font or "ixSubTitleFont"
    padding = padding or 8
    backgroundColor = backgroundColor or Color(88, 88, 88, 255)

    surface.SetFont(font)
    local textWidth, textHeight = surface.GetTextSize(text)
    local width, height = textWidth + padding * 2, textHeight + padding * 2

    ix.util.DrawBlurAt(x, y, width, height)
    surface.SetDrawColor(0, 0, 0, 40)
    surface.DrawRect(x, y, width, height)

    derma.SkinFunc("DrawImportantBackground", x, y, width, height, backgroundColor)

    surface.SetTextColor(color_white)
    surface.SetTextPos(x + padding, y + padding)
    surface.DrawText(text)

    return height
end

function PLUGIN:InitPostEntity()
    hook.Run("SetupAreaProperties")
end

function PLUGIN:ChatboxCreated()
    if (IsValid(self.panel)) then
        self.panel:Remove()
    end

    self.panel = vgui.Create("ixArea")
end

function PLUGIN:ChatboxPositionChanged(x, y, width, height)
    if (!IsValid(self.panel)) then return end

    self.panel:SetSize(width, y)
    self.panel:SetPos(32, 0)
end

function PLUGIN:ShouldDrawCrosshair()
    if (ix.area.bEditing) then return true end
end

function PLUGIN:PlayerBindPress(client, bind, bPressed)
    if (!ix.area.bEditing) then return end

    if ((bind:find("invnext") or bind:find("invprev")) and bPressed) then
        return true
    elseif (bind:find("attack2") and bPressed) then
        self:EditRightClick()
        return true
    elseif (bind:find("attack") and bPressed) then
        self:EditClick()
        return true
    elseif (bind:find("reload") and bPressed) then
        self:EditReload()
        return true
    end
end

function PLUGIN:HUDPaint()
    if (!ix.area.bEditing) then return end

    local id = LocalPlayer():GetArea()
    local area = ix.area.stored[id]
    local height = ScrH()

    local x, y = ScreenScale(16), ScreenScale(16)
    if (IsValid(ix.gui.areaEdit)) then
        x = ix.gui.areaEdit:GetX() + ix.gui.areaEdit:GetWide() + ScreenScale(16)
    end
    y = y + DrawTextBackground(x, y, L("areaEditMode"), nil, ix.config.Get("color"))

    if (!self.editStart) then
        y = y + DrawTextBackground(x, y, L("areaEditTip"), "ixSmallTitleFont")
        DrawTextBackground(x, y, L("areaRemoveTip"), "ixSmallTitleFont")
    else
        DrawTextBackground(x, y, L("areaFinishTip"), "ixSmallTitleFont")
    end

    if (area) then
        DrawTextBackground(x, height - 64 - ScreenScale(12), id, "ixSmallTitleFont", area.properties.color)
    end
end

function PLUGIN:PostDrawTranslucentRenderables(bDepth, bSkybox)
    if (bSkybox or !ix.area.bEditing) then return end

    -- draw all areas
    for k, v in pairs(ix.area.stored) do
        local center, min, max = self:GetLocalAreaPosition(v.startPosition, v.endPosition)
        local color = ColorAlpha(v.properties.color or ix.config.Get("color"), 255)

        render.DrawWireframeBox(center, Angle(0, 0, 0), min, max, color)

        cam.Start2D()
            local centerScreen = center:ToScreen()
            local _, textHeight = draw.SimpleText(
                k, "BudgetLabel", centerScreen.x, centerScreen.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if (v.type != "area") then
                draw.SimpleText(
                    "(" .. L(v.type) .. ")", "BudgetLabel",
                    centerScreen.x, centerScreen.y + textHeight, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
            end
        cam.End2D()
    end

    -- draw currently edited area
    if (self.editStart) then
        local pos = self:GetPlayerAreaTrace().HitPos
        local snap = ix.option.Get("areaEditSnap", 8)
        snap = snap == 0 and 0.1 or snap
        pos = Vector(math.Round(pos.x / snap) * snap, math.Round(pos.y / snap) * snap, math.Round(pos.z / snap) * snap)

        local center, min, max = self:GetLocalAreaPosition(self.editStart, pos)
        local color = Color(255, 255, 255, 25 + (1 + math.sin(SysTime() * 6)) * 115)

        render.DrawWireframeBox(center, Angle(0, 0, 0), min, max, color)

        cam.Start2D()
            local centerScreen = center:ToScreen()

            draw.SimpleText(L("areaNew"), "BudgetLabel",
                centerScreen.x, centerScreen.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End2D()
    end
end

function PLUGIN:EditRightClick()
    if (self.editStart) then
        self.editStart = nil
    else
        self:StopEditing()
    end
end

function PLUGIN:EditClick()
    if (!self.editStart) then
        local pos = self:GetPlayerAreaTrace().HitPos
        local snap = ix.option.Get("areaEditSnap", 8)
        snap = snap == 0 and 0.1 or snap
        pos = Vector(math.Round(pos.x / snap) * snap, math.Round(pos.y / snap) * snap, math.Round(pos.z / snap) * snap)
        
        self.editStart = pos
    elseif (self.editStart and !self.editProperties) then
        self.editProperties = true

        local panel = vgui.Create("ixAreaEdit")
        panel:MakePopup()
    end
end

function PLUGIN:EditReload()
    if (self.editStart) then return end

    local id = LocalPlayer():GetArea()
    local area = ix.area.stored[id]

    if (!area) then return end

    Derma_Query(L("areaDeleteConfirm", id), L("areaDelete"),
        L("no"), nil,
        L("yes"), function()
            net.Start("ixAreaRemove")
                net.WriteString(id)
            net.SendToServer()
        end
    )
end

function PLUGIN:ShouldDisplayArea(id)
    if (ix.area.bEditing) then return false end
end

function PLUGIN:OnAreaChanged(oldID, newID)
    local client = LocalPlayer()

    local area = ix.area.stored[newID]

    if (!area) then
        client.ixInArea = false
        return
    end

    client.ixInArea = true

    -- Play area entry sound when entering a new area
    if (ix.config.Get("areaEntrySoundEnabled", true)) then
        -- Use custom area sounds if defined, otherwise use default sounds
        local entrySounds = area.properties.entrySounds or {
            "projectparagon/sfx/Ambient/ToZone2.ogg",
            "projectparagon/sfx/Ambient/ToZone3.ogg"
        }
        
        if (istable(entrySounds) and #entrySounds > 0) then
            surface.PlaySound(entrySounds[math.random(1, #entrySounds)])
        end
    end

    if (hook.Run("ShouldDisplayArea", newID) == false or !area.properties.display) then return end

    local format = newID .. (ix.option.Get("24hourTime", false) and ", %H:%M." or ", %I:%M %p.")
    format = ix.date.GetFormatted(format)

    self.panel:AddEntry(format, area.properties.color)
end

net.Receive("ixAreaEditStart", function()
    PLUGIN:StartEditing()
end)

net.Receive("ixAreaEditEnd", function()
    PLUGIN:StopEditing()
end)

net.Receive("ixAreaAdd", function()
    local name = net.ReadString()
    local type = net.ReadString()
    local startPosition, endPosition = net.ReadVector(), net.ReadVector()
    local properties = net.ReadTable()

    if (name != "") then
        ix.area.stored[name] = {
            type = type,
            startPosition = startPosition,
            endPosition = endPosition,
            properties = properties
        }
    end
end)

net.Receive("ixAreaRemove", function()
    local name = net.ReadString()

    if (ix.area.stored[name]) then
        ix.area.stored[name] = nil
    end

    hook.Run("OnAreaRemove", name)
end)

net.Receive("ixAreaSync", function()
    local length = net.ReadUInt(32)
    local data = net.ReadData(length)
    local uncompressed = util.Decompress(data)

    if (!uncompressed) then
        ErrorNoHalt("[Helix] Unable to decompress area data!\n")
        return
    end

    -- Set the list of texts to the ones provided by the server.
    ix.area.stored = util.JSONToTable(uncompressed)

    if ( IsValid(ix.gui.developerMenu) ) then
        ix.gui.developerMenu:PopulateTabs()
    end

    hook.Run("OnAreaSync")
end)

net.Receive("ixAreaChanged", function()
    local oldID, newID = net.ReadString(), net.ReadString()

    hook.Run("OnAreaChanged", oldID, newID)
end)