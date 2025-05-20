-- gamemodes/projectparagon/plugins/charload/cl_charload.lua

if CLIENT then
    local _charLoadPanel = nil

    hook.Add("CreateCharacter", "ixCharMenuLoad_Refresh", function()
        if IsValid(_charLoadPanel) and _charLoadPanel.bActive then
            _charLoadPanel:RebuildCharacters()
        end
    end)

    hook.Add("DeleteCharacter", "ixCharMenuLoad_Refresh", function()
        if IsValid(_charLoadPanel) and _charLoadPanel.bActive then
            _charLoadPanel:RebuildCharacters()
        end
    end)
end

local menublack = ix.util.GetMaterial("projectparagon/gfx/menu/menublack.png")

local PANEL = {}
AccessorFunc(PANEL, "animationTime",      "AnimationTime",      FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundFraction", "BackgroundFraction", FORCE_NUMBER)

function PANEL:RebuildCharacters()
    if not IsValid(self.charLayout) then return end

    local panelW = self.panel:GetWide()
    local panelH = self.panel:GetTall()
    local cardW  = ScreenScale(128)
    local cardH  = ScreenScale(192)
    local spaceX = ScreenScale(8)

    -- clear old cards
    for _, child in ipairs(self.charLayout:GetChildren()) do
        child:Remove()
    end

    -- add one card per character
    local count = 0
    for _, id in ipairs(ix.characters) do
        local character = ix.char.loaded[id]
        if not character then continue end
        count = count + 1

        local faction = ix.faction.indices[character:GetFaction()]

        local card = self.charLayout:Add("DPanel")
        card:SetSize(cardW, cardH)
        function card:Paint(w, h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(menublack)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        local model = card:Add("ixModelPanel")
        model:Dock(FILL)
        model:SetModel(character:GetModel())
        model:SetFOV(ScreenScale(16))
        model.LayoutEntity = function(self)
            local ent = self.Entity
            ent:SetAngles(Angle(0, 45, 0))
            ent:SetIK(false)
            self:RunAnimation()
        end

        local name = card:Add("ixLabel")
        name:SetFont("Font-Elements-ScreenScale6")
        local txt = character:GetName()
        if #txt > 32 then txt = txt:sub(1,16) .. "..." end
        name:SetText(string.upper(txt))
        name:SizeToContents()
        name:Dock(TOP)
        name:DockMargin(0, ScreenScale(4), 0, 0)
        name:SetContentAlignment(5)

        local faclab = card:Add("ixLabel")
        faclab:SetFont("Font-Elements-ScreenScale8")
        faclab:SetText(string.upper(faction.name))
        faclab:SizeToContents()
        faclab:Dock(TOP)
        faclab:SetContentAlignment(5)
        faclab:SetTextColor(team.GetColor(faction.index))

        local btnDelete = card:Add("ixMenuButton")
        btnDelete:Dock(BOTTOM)
        btnDelete:DockMargin(5,5,5,5)
        btnDelete:SetText("DELETE")
        btnDelete:SetContentAlignment(5)
        btnDelete.DoClick = function()
            -- full-screen delete confirmation
            local overlay = vgui.Create("DPanel")
            overlay:SetSize(ScrW(), ScrH())
            overlay:SetPos(0, 0)
            overlay:MakePopup()
            overlay:SetMouseInputEnabled(true)
            overlay:SetKeyboardInputEnabled(true)

            function overlay:Paint(w, h)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(menublack)
                surface.DrawTexturedRect(0, 0, w, h)
            end

            -- central container
            local cw, ch = ScrW() * 0.6, ScrH() * 0.4
            local container = vgui.Create("DPanel", overlay)
            container:SetSize(cw, ch)
            container:SetPos((ScrW() - cw) * 0.5, (ScrH() - ch) * 0.5)
            function container:Paint(w, h)
                -- no outline, transparent over the backdrop
            end

            -- header
            local header = vgui.Create("DLabel", container)
            header:SetFont("Font-Elements-ScreenScale14")
            header:SetText("ARE YOU SURE?")
            header:SetTextColor(Color(200,50,50))
            header:SizeToContents()
            header:SetPos((cw - header:GetWide()) * 0.5, ScreenScale(16))

            -- subtitle
            local sub = vgui.Create("DLabel", container)
            sub:SetFont("Font-Elements-ScreenScale10")
            sub:SetText("This character will be permanently removed!")
            sub:SetTextColor(color_white)
            sub:SizeToContents()
            sub:SetPos((cw - sub:GetWide()) * 0.5, header.y + header:GetTall() + ScreenScale(8))

            -- buttons
            local btnW = (cw - ScreenScale(16)) * 0.5
            local btnH = ScreenScale(48)
            local baseY = ch - btnH - ScreenScale(16)

            local btnYes = vgui.Create("ixMenuButton", container)
            btnYes:SetText("YES")
            btnYes:SetSize(btnW, btnH)
            btnYes:SetPos(0, baseY)
            btnYes:SetContentAlignment(5)
            btnYes.DoClick = function()
                net.Start("ixCharacterDelete")
                  net.WriteUInt(character:GetID(), 32)
                net.SendToServer()
                overlay:Remove()
            end

            local btnNo = vgui.Create("ixMenuButton", container)
            btnNo:SetText("NO")
            btnNo:SetSize(btnW, btnH)
            btnNo:SetPos(btnW + ScreenScale(16), baseY)
            btnNo:SetContentAlignment(5)
            btnNo.DoClick = function()
                overlay:Remove()
            end
        end

        local btnLoad = card:Add("ixMenuButton")
        btnLoad:Dock(BOTTOM)
        btnLoad:DockMargin(5,5,5,0)
        btnLoad:SetText("LOAD")
        btnLoad:SetContentAlignment(5)
        btnLoad.DoClick = function()
            net.Start("ixCharacterChoose")
              net.WriteUInt(character:GetID(), 32)
            net.SendToServer()
        end
    end

    -- center the layout
    local totalW = cardW * count + spaceX * math.max(0, count - 1)
    self.charLayout:SetWide(totalW)
    self.charLayout:SetTall(cardH)
    self.charLayout:SetPos(
        (panelW  - totalW) * 0.5,
        (panelH - cardH)  * 0.5
    )
end

function PANEL:Init()
    local parent = self:GetParent()
    if CLIENT then
        _charLoadPanel = self
    end

    self.animationTime      = 1
    self.backgroundFraction = 1
    self.bActive            = false

    -- main subpanel
    self.panel = self:AddSubpanel("main")
    self.panel:SetTitle("LOAD CHARACTER")
    self.panel.avoidPadding = true
    self.panel.OnSetActive = function()
        self:RebuildCharacters()
        self:CreateAnimation(self.animationTime, {
            index  = 2,
            target = {backgroundFraction = 1},
            easing = "outQuint"
        })
    end

    -- icon layout
    self.charLayout = self.panel:Add("DIconLayout")
    self.charLayout:SetSpaceX(ScreenScale(8))
    self.charLayout:SetSpaceY(ScreenScale(8))

    -- initial build
    self:RebuildCharacters()

    -- return button
    local back = self.panel:Add("ixMenuButton")
    back:Dock(BOTTOM)
    back:DockMargin(0, ScreenScale(4), 0, 0)
    back:SetText("BACK TO MAIN MENU")
    back:SetContentAlignment(5)
    back.DoClick = function()
        self:SlideDown()
        parent.mainPanel:Undim()
    end

    self:SetActiveSubpanel("main", 0)
end

function PANEL:OnSlideUp()
    self.bActive = true
    self:RebuildCharacters()
end

function PANEL:OnSlideDown()
    self.bActive = false
end

function PANEL:OnCharacterDeleted(character)
    if self.bActive then
        self:RebuildCharacters()
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(150, 150, 150, 255)
    surface.SetMaterial(menublack)
    surface.DrawTexturedRect(0, 0, w * 0.5, h)
    surface.DrawTexturedRect(w * 0.5, 0, w * 0.5, h)
end

vgui.Register("ixCharMenuLoad", PANEL, "ixCharMenuPanel")
