local menu_background = ix.util.GetMaterial("projectparagon/paragon/paragon_menu_alt.png")
local menu_image = ix.util.GetMaterial("projectparagon/gfx/menu/173back.png")

local gradient = surface.GetTextureID("vgui/gradient-d")
local audioFadeInTime = 2
local animationTime = 0.5
local matrixZScale = Vector(1, 1, 0.0001)

-- character menu panel
DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

function PANEL:Init()
	self:SetSize(self:GetParent():GetSize())
	self:SetPos(0, 0)

	self.childPanels = {}
	self.subpanels = {}
	self.activeSubpanel = ""

	self.currentDimAmount = 0
	self.currentY = 0
	self.currentScale = 1
	self.currentAlpha = 255
	self.targetDimAmount = 255
	self.targetScale = 0.9
end

function PANEL:Dim(length, callback)
	length = length or animationTime
	self.currentDimAmount = 0

	self:CreateAnimation(length, {
		target = {
			currentDimAmount = self.targetDimAmount,
			currentScale = self.targetScale
		},
		easing = "outCubic",
		OnComplete = callback
	})

	self:OnDim()
end

function PANEL:Undim(length, callback)
	length = length or animationTime
	self.currentDimAmount = self.targetDimAmount

	self:CreateAnimation(length, {
		target = {
			currentDimAmount = 0,
			currentScale = 1
		},
		easing = "outCubic",
		OnComplete = callback
	})

	self:OnUndim()
end

function PANEL:OnDim()
end

function PANEL:OnUndim()
end

function PANEL:Paint(width, height)
	BaseClass.Paint(self, width, height)
	local amount = self.currentDimAmount

	if (amount > 0) then
		local color = Color(0, 0, 0, amount)

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, width, height)
	end
end

vgui.Register("ixCharMenuPanel", PANEL, "ixSubpanelParent")

-- character menu main button list
PANEL = {}

function PANEL:Init()
	local parent = self:GetParent()
	self:SetSize(parent:GetWide() * 0.3, parent:GetTall())

	self:GetVBar():SetWide(0)
	self:GetVBar():SetVisible(false)
end

function PANEL:Add(name)
	local panel = vgui.Create(name, self)
	panel:Dock(TOP)

	return panel
end

function PANEL:SizeToContents()
	self:GetCanvas():InvalidateLayout(true)

	-- if the canvas has extra space, forcefully dock to the bottom so it doesn't anchor to the top
	if (self:GetTall() > self:GetCanvas():GetTall()) then
		self:GetCanvas():Dock(TOP)
	else
		self:GetCanvas():Dock(NODOCK)
	end
end

vgui.Register("ixCharMenuButtonList", PANEL, "DScrollPanel")

-- main character menu panel
PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
	local parent = self:GetParent()
	local padding = ScreenScale(16)
	local halfWidth = ScrW() * 0.5
	local halfPadding = padding * 0.5
	local bHasCharacter = #ix.characters > 0

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:DockPadding(padding, padding, padding, padding)

	-- button list
	self.mainButtonList = self:Add("ixCharMenuButtonList")
	self.mainButtonList:Dock(LEFT)
	self.mainButtonList:DockMargin(ScreenScale(64), ScreenScale(80), 0, 0)

	-- create character button
	local createButton = self.mainButtonList:Add("ixMenuButton")
	createButton:SetText("New Character")
	createButton:SetFont("ParagonMenuButton")
	createButton:SetTall(createButton:GetTall() * 1.5)
	createButton:DockMargin(0, 0, 0, ScreenScale(8))
	createButton.DoClick = function()
		local maximum = hook.Run("GetMaxPlayerCharacter", LocalPlayer()) or ix.config.Get("maxCharacters", 5)
		-- don't allow creation if we've hit the character limit
		if (#ix.characters >= maximum) then
			self:GetParent():ShowNotice(3, L("maxCharacters"))
			return
		end

		self:Dim()
		parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
		parent.newCharacterPanel:SlideUp()
	end

	-- load character button
	self.loadButton = self.mainButtonList:Add("ixMenuButton")
	self.loadButton:SetText("Load Character")
	self.loadButton:SetFont("ParagonMenuButton")
	self.loadButton:SetTall(self.loadButton:GetTall() * 1.5)
	self.loadButton:DockMargin(0, 0, 0, ScreenScale(8))
	self.loadButton.DoClick = function()
		self:Dim()
		parent.loadCharacterPanel:SlideUp()
	end

	if (!bHasCharacter) then
		self.loadButton:SetDisabled(true)
	end

	-- community button
	local extraURL = ix.config.Get("communityURL", "")
	local extraText = ix.config.Get("communityText", "@community")

	if (extraURL != "" and extraText != "") then
		if (extraText:sub(1, 1) == "@") then
			extraText = L(extraText:sub(2))
		end

		local extraButton = self.mainButtonList:Add("ixMenuButton")
		extraButton:SetText(extraText, true)
		extraButton:SetFont("ParagonMenuButton")
		extraButton:SetTall(extraButton:GetTall() * 1.5)
		extraButton:DockMargin(0, 0, 0, ScreenScale(8))
		extraButton.DoClick = function()
			gui.OpenURL(extraURL)
		end
	end

	-- leave/return button
	self.returnButton = self.mainButtonList:Add("ixMenuButton")
	self:UpdateReturnButton()
	self.returnButton.DoClick = function()
		if (self.bUsingCharacter) then
			parent:Close()
		else
			Derma_Query("Are you sure you want to leave?", "Helix", "Yes", function()
				self:Dim(2, function()
					RunConsoleCommand("disconnect")
				end)
			end, "No")
		end
	end

	self.mainButtonList:SizeToContents()
end

function PANEL:UpdateReturnButton(bValue)
	if (bValue != nil) then
		self.bUsingCharacter = bValue
	end

	self.returnButton:SetText(self.bUsingCharacter and "RETURN" or "DISCONNECT")
	self.returnButton:SetFont("ParagonMenuButton")
	self.returnButton:SetTall(self.returnButton:GetTall() * 1.5)
	self.returnButton:SizeToContents()
end

function PANEL:OnDim()
	-- disable input on this panel since it will still be in the background while invisible - prone to stray clicks if the
	-- panels overtop slide out of the way
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:OnUndim()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	-- we may have just deleted a character so update the status of the return button
	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:UpdateReturnButton()
end

function PANEL:OnClose()
	for _, v in pairs(self:GetChildren()) do
		if (IsValid(v)) then
			v:SetVisible(false)
		end
	end
end

function PANEL:PerformLayout(width, height)
	local padding = self:GetPadding()

	self.mainButtonList:SetPos(padding, height - self.mainButtonList:GetTall() - padding)
end

vgui.Register("ixCharMenuMain", PANEL, "ixCharMenuPanel")

-- container panel
PANEL = {}

function PANEL:Init()
	if (IsValid(ix.gui.loading)) then
		ix.gui.loading:Remove()
	end

	if (IsValid(ix.gui.characterMenu)) then
		if (IsValid(ix.gui.characterMenu.channel)) then
			ix.gui.characterMenu.channel:Stop()
		end

		ix.gui.characterMenu:Remove()
	end

	ix.gui.characterMenu = self

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	-- main menu panel
	self.mainPanel = self:Add("ixCharMenuMain")

	-- new character panel
	self.newCharacterPanel = self:Add("ixCharMenuNew")
	self.newCharacterPanel:SlideDown(0)

	-- load character panel
	self.loadCharacterPanel = self:Add("ixCharMenuLoad")
	self.loadCharacterPanel:SlideDown(0)

	-- notice bar
	self.notice = self:Add("ixNoticeBar")

	-- finalization
	self:MakePopup()
	self.currentAlpha = 255
	self.volume = 0

	ix.gui.characterMenu = self

	if (!IsValid(ix.gui.intro)) then
		self:PlayMusic()
	end

	hook.Run("OnCharacterMenuCreated", self)
end

function PANEL:PlayMusic()
	local path = "sound/" .. ix.config.Get("music")
	local url = path:match("http[s]?://.+")
	local play = url and sound.PlayURL or sound.PlayFile
	path = url and url or path

	play(path, "noplay", function(channel, error, message)
		if (!IsValid(self) or !IsValid(channel)) then
			return
		end

		channel:SetVolume(self.volume or 0)
		channel:Play()

		self.channel = channel

		self:CreateAnimation(audioFadeInTime, {
			index = 10,
			target = {volume = 1},

			Think = function(animation, panel)
				if (IsValid(panel.channel)) then
					panel.channel:SetVolume(self.volume)
				end
			end
		})

		local length = channel:GetLength()
        timer.Create("ixCharacterMusic", length, 1, function()
            if (IsValid(self) and IsValid(self.channel)) then
                self.channel:Stop()
                self.channel = nil

                self:PlayMusic()
            end
        end)
	end)
end

function PANEL:ShowNotice(type, text)
	self.notice:SetType(type)
	self.notice:SetText(text)
	self.notice:Show()
end

function PANEL:HideNotice()
	if (IsValid(self.notice) and !self.notice:GetHidden()) then
		self.notice:Slide("up", 0.5, true)
	end
end

function PANEL:OnCharacterDeleted(character)
	if (#ix.characters == 0) then
		self.mainPanel.loadButton:SetDisabled(true)
		self.mainPanel:Undim() -- undim since the load panel will slide down
	else
		self.mainPanel.loadButton:SetDisabled(false)
	end

	self.loadCharacterPanel:OnCharacterDeleted(character)
end

function PANEL:OnCharacterLoadFailed(error)
	self.loadCharacterPanel:SetMouseInputEnabled(true)
	self.loadCharacterPanel:SlideUp()
	self:ShowNotice(3, error)
end

function PANEL:IsClosing()
	return self.bClosing
end

function PANEL:Close(bFromMenu)
	self.bClosing = true
	self.bFromMenu = bFromMenu

	local fadeOutTime = animationTime * 8

	self:CreateAnimation(fadeOutTime, {
		index = 1,
		target = {currentAlpha = 0},

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end,

		OnComplete = function(animation, panel)
			panel:Remove()
		end
	})

	self:CreateAnimation(fadeOutTime - 0.1, {
		index = 10,
		target = {volume = 0},

		Think = function(animation, panel)
			if (IsValid(panel.channel)) then
				panel.channel:SetVolume(self.volume)
			end
		end,

		OnComplete = function(animation, panel)
			if (IsValid(panel.channel)) then
				panel.channel:Stop()
				panel.channel = nil
			end
		end
	})

	-- hide children if we're already dimmed
	if (bFromMenu) then
		for _, v in pairs(self:GetChildren()) do
			if (IsValid(v)) then
				v:SetVisible(false)
			end
		end
	else
		-- fade out the main panel quicker because it significantly blocks the screen
		self.mainPanel.currentAlpha = 255

		self.mainPanel:CreateAnimation(animationTime * 2, {
			target = {currentAlpha = 0},
			easing = "outQuint",

			Think = function(animation, panel)
				panel:SetAlpha(panel.currentAlpha)
			end,

			OnComplete = function(animation, panel)
				panel:SetVisible(false)
			end
		})
	end

	-- relinquish mouse control
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(false)
end

local surface = surface
local DrawLine = surface.DrawLine
local lastFlashTime = 0
local isVisible = true
local flashMinInterval = 0.1
local flashMaxInterval = 0.5
local flashDuration = 0.1

function PANEL:Paint(width, height)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(menu_background)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

    -- Handle 173 image flashing
    local currentTime = CurTime()
    
    -- Check if it's time for a new flash state
    if currentTime > lastFlashTime then
        isVisible = not isVisible
        -- Set the next flash time with some randomness
        lastFlashTime = currentTime + (isVisible and math.Rand(flashMinInterval, flashMaxInterval) or flashDuration)
    end
    
    -- Draw SCP-173 image with appropriate alpha
    local imageWidth, imageHeight = 212, 341
    local posX = width - imageWidth - 5
    local posY = 750

    -- Alpha value is either 255 (fully visible) or 0 (invisible)
    local alpha = isVisible and 255 or 0
    
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(menu_image)
    surface.DrawTexturedRect(posX, posY, imageWidth, imageHeight)
end

function PANEL:PaintOver(width, height)
	if (self.bClosing and self.bFromMenu) then
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, width, height)
	end
end

function PANEL:OnRemove()
    if (IsValid(self.channel)) then
        self.channel:Stop()
        self.channel = nil
    end

    if (timer.Exists("ixCharacterMusic")) then
        timer.Remove("ixCharacterMusic")
    end
end

vgui.Register("ixCharMenu", PANEL, "EditablePanel")

if (IsValid(ix.gui.characterMenu)) then
	ix.gui.characterMenu:Remove()

	timer.Simple(0.1, function()
		ix.gui.characterMenu = vgui.Create("ixCharMenu")
	end)
end
