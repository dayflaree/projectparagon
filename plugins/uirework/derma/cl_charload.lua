local menublack = ix.util.GetMaterial("90/projectparagon/ui/menu/menu_black.png")
local menuwhite = ix.util.GetMaterial("90/projectparagon/ui/menu/menu_white.png")

-- character load panel
local PANEL = {}

AccessorFunc(PANEL, "animationTime", "AnimationTime", FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundFraction", "BackgroundFraction", FORCE_NUMBER)

function PANEL:Init()
	local parent = self:GetParent()

	self.animationTime = 1
	self.backgroundFraction = 1

	-- main panel
	self.panel = self:AddSubpanel("main")
	self.panel:SetTitle("loadTitle")
	self.panel.OnSetActive = function()
		self:CreateAnimation(self.animationTime, {
			index = 2,
			target = {backgroundFraction = 1},
			easing = "outQuint",
		})
	end

	self.panel.avoidPadding = true

	-- Character Count
	local Count = 0

	for _, _ in pairs(ix.characters) do
		Count = Count + 1
	end

	self.CharacterCount = Count

	local charImageH = ScreenScale(192)
	local charPanelW = ScreenScale(128)
	local charTextH = ScreenScale(16)
	local margin = ScreenScale(8)

	local panelLoad = self.panel:Add("Panel")

	panelLoad:SetSize((6) * charPanelW + ((4 - 1) * margin), ScreenScale(192))
	panelLoad:Center()

	self.charactersPanel = panelLoad:Add("Panel")
	self.charactersPanel:SetSize(panelLoad:GetWide(), ScreenScale(192))
	self.charactersPanel:Dock(TOP)

	self.characterPanel = self.charactersPanel:Add("Panel")

	if self.CharacterCount == 1 then
		self.characterPanel:SetSize(charPanelW, charImageH)
	else
		self.characterPanel:SetSize((self.CharacterCount) * charPanelW + ((self.CharacterCount - 1) * margin), charImageH)
	end

	self.characterPanel:Center()
	local x, y = self.characterPanel:GetPos()
	self.characterPanel:SetPos(x, 0)

	for i = 1, #ix.characters do
		local id = ix.characters[i]
		local character = ix.char.loaded[id]

		if (!character) then
			continue
		end

		local index = character:GetFaction()
		local faction = ix.faction.indices[index]

		local image = self.characterPanel:Add("DPanel")
		image:Dock(LEFT)

		if i == 1 then
			image:DockMargin(0, 0, 5, 0)
		else
			image:DockMargin(0, 0, 5, 0)
		end

		image.id = character:GetID()
		image:SetSize( charPanelW, charImageH )
		image.Paint = function(self, w, h)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(menublack)
			surface.DrawTexturedRect(0, 0, h, h)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local model = image:Add("ixModelPanel")
		model:SetModel(character:GetModel())
		model:Dock(FILL)
		model:SetFOV(ScreenScale(16))
		model.PaintModel = model.Paint
		model.LayoutEntity = function(self)
			local entity = self.Entity
		
			entity:SetAngles(Angle(0, 45, 0))
			entity:SetIK(false)
		
			if (self.copyLocalSequence) then
				entity:SetSequence(LocalPlayer():GetSequence())
				entity:SetPoseParameter("move_yaw", 360 * LocalPlayer():GetPoseParameter("move_yaw") - 180)
			end
		
			self:RunAnimation()
		end

		local nameText = image:Add("ixLabel")
		nameText:SetFont("Font-Elements-ScreenScale6")

		if string.len(character:GetName()) > 32 then
			nameText:SetText(string.upper(string.sub(character:GetName(), 1, 16) .."..."))
		else
			nameText:SetText(string.upper(character:GetName()))
		end

		nameText:SizeToContents()
		nameText:Dock(TOP)
		nameText:DockMargin(0, ScreenScale(10 / 3), 0, 0)
		nameText:SetContentAlignment(5)

		local factionText = image:Add("ixLabel")
		factionText:SetFont("Font-Elements-ScreenScale8")
		factionText:SetText(string.upper(faction.name))

		factionText:SizeToContents()
		factionText:Dock(TOP)
		factionText:SetContentAlignment(5)
		factionText:SetTextColor(team.GetColor(faction.index))

		local deleteButton = image:Add("ixMenuButton")
		deleteButton:SetText("Delete")
		deleteButton:SetContentAlignment(5)
		deleteButton:Dock(BOTTOM)
		deleteButton:DockMargin(5, 5, 5, 5)
		deleteButton.DoClick = function()
			self.character = character
			self:SetActiveSubpanel("delete")
		end
		deleteButton.Paint = function(self, w, h)
			if !self:IsHovered() then
				surface.SetDrawColor(50, 50, 50, 255)
				surface.SetMaterial(menublack)
				surface.DrawTexturedRect(0, 0, w, h)
				
				surface.SetDrawColor(color_white)
			else
				surface.SetDrawColor(20, 20, 20, 255)
				surface.DrawRect(0, 0, w, h)
				
				surface.SetDrawColor(Color(100, 100, 100, 255))
			end
	
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local loadButton = image:Add("ixMenuButton")
		loadButton:SetText("Load")
		loadButton:SetContentAlignment(5)
		loadButton:Dock(BOTTOM)
		loadButton:DockMargin(5, 5, 5, 0)
		loadButton.DoClick = function()
			self.character = character
			self:SetMouseInputEnabled(false)
			self:Slide("down", self.animationTime, function()
				net.Start("ixCharacterChoose")
					net.WriteUInt(self.character:GetID(), 32)
				net.SendToServer()
			end, true)
		end
		loadButton.Paint = function(self, w, h)
			if !self:IsHovered() then
				surface.SetDrawColor(50, 50, 50, 255)
				surface.SetMaterial(menublack)
				surface.DrawTexturedRect(0, 0, w, h)
				
				surface.SetDrawColor(color_white)
			else
				surface.SetDrawColor(20, 20, 20, 255)
				surface.DrawRect(0, 0, w, h)
				
				surface.SetDrawColor(Color(100, 100, 100, 255))
			end
	
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	local back = self.panel:Add("ixMenuButton")
	back:SetText("Return to Main Menu")
	back:SetContentAlignment(5)
	back:Dock(BOTTOM)
	back.DoClick = function()
		self:SlideDown()
		parent.mainPanel:Undim()
	end
	back.Paint = function(self, w, h)
		if !self:IsHovered() then
			surface.SetDrawColor(50, 50, 50, 255)
			surface.SetMaterial(menublack)
			surface.DrawTexturedRect(0, 0, w, h)
			
			surface.SetDrawColor(color_white)
		else
			surface.SetDrawColor(20, 20, 20, 255)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(Color(100, 100, 100, 255))
		end

		surface.DrawOutlinedRect(0, 0, w, h)
	end

	-- character deletion panel
	self.delete = self:AddSubpanel("delete")
	self.delete:SetTitle(nil)
	self.delete.OnSetActive = function()
	self.delete.avoidPadding = true
		self.deleteModel:SetModel(self.character:GetModel())
		if self.character:GetData("skin") then
			self.deleteModel.Entity:SetSkin(self.character:GetData("skin"))
		end

		local bodygroups = self.character:GetData("groups", nil)

		if (istable(bodygroups)) then
			for k, v in pairs(bodygroups) do
				if self.deleteModel.Entity then
					self.deleteModel.Entity:SetBodygroup(k, v)
				end
			end
		end

		self:CreateAnimation(self.animationTime, {
			index = 2,
			target = {backgroundFraction = 0},
			easing = "outQuint"
		})
	end

	local deleteInfo = self.delete:Add("Panel")
	deleteInfo:SetSize(parent:GetWide() * 0.5, parent:GetTall())
	deleteInfo:Dock(LEFT)

	self.deleteModel = deleteInfo:Add("ixModelPanel")
	self.deleteModel:Dock(FILL)
	self.deleteModel:SetModel("models/error.mdl")
	self.deleteModel:SetFOV(78)
	self.deleteModel.PaintModel = self.deleteModel.Paint

	local deleteNag = self.delete:Add("Panel")
	deleteNag:SetTall(parent:GetTall() * 0.6)
	deleteNag:Dock(BOTTOM)

	local deleteTitle = deleteNag:Add("ixLabel")
	deleteTitle:SetFont("Font-Elements-ScreenScale14")
	deleteTitle:SetText(string.upper("are you sure?"))
	deleteTitle:SetTextColor(Color(200, 50, 50, 255))
	deleteTitle:SetContentAlignment(4)
	deleteTitle:SizeToContents()
	deleteTitle:Dock(TOP)

	local deleteText = deleteNag:Add("ixLabel")
	deleteText:SetFont("Font-Elements-ScreenScale10")
	deleteText:SetText("This character will be permanently removed!")
	deleteText:SetTextColor(color_white)
	deleteText:SetContentAlignment(7)
	deleteText:Dock(TOP)
	deleteText:SizeToContents()

	local yesnoPanel = deleteNag:Add("Panel")
	yesnoPanel:Dock(TOP)
	yesnoPanel:SetTall(ScreenScale(60 / 3))
	yesnoPanel:DockMargin(0, margin, 0, 0)

	local yes = yesnoPanel:Add("ixMenuButton")
	yes:Dock(LEFT)
	yes:SetWide(ScreenScale(60))
	yes:DockMargin(0, 0, 5, 0)
	yes:SetFont("Font-Elements-ScreenScale10")
	yes:SetText(string.upper("yes"))
	yes:SetContentAlignment(5)
	yes.Paint = function(self, w, h) end
	yes.DoClick = function()
		self.CharacterCount = self.CharacterCount - 1

		local id = self.character:GetID()

		parent:ShowNotice(1, L("deleteComplete", self.character:GetName()))

		self:SetActiveSubpanel("main")

		net.Start("ixCharacterDelete")
			net.WriteUInt(id, 32)
		net.SendToServer()

		for k, v in pairs(self.characterPanel:GetChildren()) do
			if v.id == id then
				v:Remove()
			end
		end

		if self.CharacterCount == 1 then
			self.characterPanel:SetSize(charPanelW, charImageH)
		else
			self.characterPanel:SetSize((self.CharacterCount) * charPanelW + ((self.CharacterCount - 1) * margin), charImageH)
		end

		self.characterPanel:SetPos(0, 0)
	end
	yes.Paint = function(self, w, h)
		if !self:IsHovered() then
			surface.SetDrawColor(50, 50, 50, 255)
			surface.SetMaterial(menublack)
			surface.DrawTexturedRect(0, 0, w, h)
			
			surface.SetDrawColor(color_white)
		else
			surface.SetDrawColor(20, 20, 20, 255)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(Color(100, 100, 100, 255))
		end

		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local no = yesnoPanel:Add("ixMenuButton")
	no:Dock(LEFT)
	no:SetWide(ScreenScale(60))
	no:SetFont("Font-Elements-ScreenScale10")
	no:SetText(string.upper("no"))
	no:SetContentAlignment(5)
	no.Paint = function(self, w, h) end
	no.DoClick = function()
		self:SetActiveSubpanel("main")
	end
	no.Paint = function(self, w, h)
		if !self:IsHovered() then
			surface.SetDrawColor(50, 50, 50, 255)
			surface.SetMaterial(menublack)
			surface.DrawTexturedRect(0, 0, w, h)
			
			surface.SetDrawColor(color_white)
		else
			surface.SetDrawColor(20, 20, 20, 255)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(Color(100, 100, 100, 255))
		end

		surface.DrawOutlinedRect(0, 0, w, h)
	end

	-- finalize setup
	self:SetActiveSubpanel("main", 0)
end

function PANEL:OnCharacterDeleted(character)
	local parent = self:GetParent()
	local bHasCharacter = #ix.characters > 0

	if (self.bActive and #ix.characters == 0) then
		self:SlideDown()
		parent.mainPanel.loadButton:SetDisabled(true)
		parent.mainPanel.loadButton:SetTextColor(Color(90, 90, 90, 255))

		parent.mainPanel.loadButton.Paint = function( self, w, h )
			surface.SetDrawColor(Color(0, 0, 0, 0));
			surface.DrawRect(0,0, w, h);

			if self:IsHovered() and (bHasCharacter) then
				draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color(78, 79, 100, 240) )
			end
		end

		parent.mainPanel.loadButton.OnCursorEntered = function()
			if (!bHasCharacter) then
				parent.mainPanel.loadButton:SetTextColor(Color(90, 90, 90, 255))
				return
			end
		end

		parent.mainPanel.loadButton.OnCursorExited = function()
			if (!bHasCharacter) then
				parent.mainPanel.loadButton:SetTextColor(Color(90, 90, 90, 255))
				return
			end
		end
	end
end

function PANEL:OnSlideUp()
	self.bActive = true
end

function PANEL:OnSlideDown()
	self.bActive = false
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(150, 150, 150, 255)
	surface.SetMaterial(menublack)
	surface.DrawTexturedRect(0, 0, width / 2, height)
	surface.DrawTexturedRect(width / 2, 0, width / 2, height)
end

vgui.Register("ixCharMenuLoad", PANEL, "ixCharMenuPanel")
