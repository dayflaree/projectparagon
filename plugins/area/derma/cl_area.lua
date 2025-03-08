-- area entry
DEFINE_BASECLASS("Panel")
local PANEL = {}

AccessorFunc(PANEL, "text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "tickSound", "TickSound", FORCE_STRING)
AccessorFunc(PANEL, "tickSoundRange", "TickSoundRange")
AccessorFunc(PANEL, "backgroundAlpha", "BackgroundAlpha", FORCE_NUMBER)
AccessorFunc(PANEL, "expireTime", "ExpireTime", FORCE_NUMBER)
AccessorFunc(PANEL, "animationTime", "AnimationTime", FORCE_NUMBER)
-- New accessor for entry sounds
AccessorFunc(PANEL, "entrySounds", "EntrySounds")

function PANEL:Init()
    self:DockPadding(4, 4, 4, 4)
    self:SetSize(self:GetParent():GetWide(), 0)

    self.label = self:Add("DLabel")
    self.label:Dock(FILL)
    self.label:SetFont("ixMediumLightFont")
    self.label:SetTextColor(color_white)
    self.label:SetExpensiveShadow(1, color_black)
    self.label:SetText("Area")

    self.text = ""
    self.tickSound = ix.config.Get("areaTickSound", "npc/roller/mine/rmine_chirp_ping1.wav")
    self.tickSoundRange = {ix.config.Get("areaTickSoundMin", 190), ix.config.Get("areaTickSoundMax", 200)}
    self.backgroundAlpha = 255
    self.expireTime = ix.config.Get("areaExpireTime", 8)
    self.animationTime = 2
    
    -- Default entry sounds, can be overridden
    self.entrySounds = {
        "ProjectParagon/GameSounds/scpcb/Ambient/ToZone2.ogg",
        "ProjectParagon/GameSounds/scpcb/Ambient/ToZone3.ogg"
    }

    self.character = 1
    self.createTime = RealTime()
    self.currentAlpha = 255
    self.currentHeight = 0
    self.nextThink = RealTime()
    self.hasPlayedEntrySound = false
end

function PANEL:PlayEntrySound()
    if self.entrySounds and #self.entrySounds > 0 then
        local soundToPlay = self.entrySounds[math.random(1, #self.entrySounds)]
        surface.PlaySound(soundToPlay)
    end
end

function PANEL:Show()
    -- Play entry sound immediately when the panel is going to be shown
    if not self.hasPlayedEntrySound then
        self:PlayEntrySound()
        self.hasPlayedEntrySound = true
    end

    self:CreateAnimation(0.5, {
        index = -1,
        target = {currentHeight = self.label:GetTall() + 8},
        easing = "outQuint",

        Think = function(animation, panel)
            panel:SetTall(panel.currentHeight)
        end
    })
end

function PANEL:SetFont(font)
    self.label:SetFont(font)
end

function PANEL:SetText(text)
    if (text:sub(1, 1) == "@") then
        text = L(text:sub(2))
    end

    self.label:SetText(text)
    self.text = text
    self.character = 1
end

-- New function to set entry sounds
function PANEL:SetEntrySounds(sounds)
    if istable(sounds) and #sounds > 0 then
        self.entrySounds = sounds
    end
end

function PANEL:Think()
    local time = RealTime()

    if (time >= self.nextThink) then
        if (self.character < self.text:utf8len()) then
            self.character = self.character + 1
            self.label:SetText(string.utf8sub(self.text, 1, self.character))

            if (ix.config.Get("areaTickSoundEnabled", true)) then
                LocalPlayer():EmitSound(self.tickSound, 100, math.random(self.tickSoundRange[1], self.tickSoundRange[2]))
            end
        end

        if (time >= self.createTime + self.expireTime and !self.bRemoving) then
            self:Remove()
        end

        self.nextThink = time + 0.05
    end
end

function PANEL:SizeToContents()
    self:SetWide(self:GetParent():GetWide())

    self.label:SetWide(self:GetWide())
    self.label:SizeToContentsY()
end

function PANEL:Paint(width, height)
    self.backgroundAlpha = math.max(self.backgroundAlpha - 200 * FrameTime(), 0)

    derma.SkinFunc("PaintAreaEntry", self, width, height)
end

function PANEL:Remove()
    if (self.bRemoving) then return end

    self:CreateAnimation(self.animationTime, {
        target = {currentAlpha = 0},

        Think = function(animation, panel)
            panel:SetAlpha(panel.currentAlpha)
        end,

        OnComplete = function(animation, panel)
            panel:CreateAnimation(0.5, {
                index = -1,
                target = {currentHeight = 0},
                easing = "outQuint",

                Think = function(_, sizePanel)
                    sizePanel:SetTall(sizePanel.currentHeight)
                end,

                OnComplete = function(_, sizePanel)
                    sizePanel:OnRemove()
                    BaseClass.Remove(sizePanel)
                end
            })
        end
    })

    self.bRemoving = true
end

function PANEL:OnRemove()
end

vgui.Register("ixAreaEntry", PANEL, "Panel")

-- main panel
PANEL = {}

function PANEL:Init()
    local chatWidth, _ = chat.GetChatBoxSize()
    local _, chatY = chat.GetChatBoxPos()

    self:SetSize(chatWidth, chatY)
    self:SetPos(32, 0)
    self:ParentToHUD()

    self.entries = {}
    ix.gui.area = self
end

function PANEL:AddEntry(entry, color, entrySounds)
    if (!entry) then return end
    if (!ix.config.Get("areaShowNotifications", true)) then return end

    color = color or ix.config.Get("color")

    local id = #self.entries + 1
    local panel = entry

    if (isstring(entry)) then
        panel = self:Add("ixAreaEntry")
        panel:SetText(entry)
    end

    panel:SetBackgroundColor(color)
    
    -- Set custom entry sounds if provided
    if entrySounds and istable(entrySounds) then
        panel:SetEntrySounds(entrySounds)
    end
    
    panel:SizeToContents()
    panel:Dock(BOTTOM)
    panel:Show()
    panel.OnRemove = function()
        for k, v in pairs(self.entries) do
            if (v == panel) then
                table.remove(self.entries, k)
                break
            end
        end
    end

    self.entries[id] = panel
    return id
end

function PANEL:GetEntries()
    return self.entries
end

vgui.Register("ixArea", PANEL, "Panel")

-- Hook into the area notification system to ensure sounds play when new areas are entered
hook.Add("AreaEntered", "ixPlayAreaSound", function(client, area)
    if CLIENT and client == LocalPlayer() and ix.gui.area then
        -- Setup default sounds for the notification
        local entrySounds = {
            "ProjectParagon/GameSounds/scpcb/Ambient/ToZone2.ogg",
            "ProjectParagon/GameSounds/scpcb/Ambient/ToZone3.ogg"
        }
        
        -- Play a sound directly, in case the panel method doesn't work
        surface.PlaySound(entrySounds[math.random(1, #entrySounds)])
    end
end)