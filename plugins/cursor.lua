local PLUGIN = PLUGIN
PLUGIN.name = "Custom cursor"
PLUGIN.author = "MediQ"
PLUGIN.description = "Add some custom cursors for helix framework"
PLUGIN.version = 1.0

IX_CURSOR_MATERIAL = Material("projectparagon/gfx/cursor.PNG") -- Your own material for cursor

if CLIENT then

	-- Draw the new cursor
	function draw.CustCursor( material )
		local pos_x, pos_y = input.GetCursorPos()

		if vgui.CursorVisible() then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(material)
			surface.DrawTexturedRect(pos_x, pos_y, ScreenScale(5), ScreenScale(9))
		end
	end

	-- Post draw cursor
	function PLUGIN:PostRenderVGUI()
		draw.CustCursor(IX_CURSOR_MATERIAL)
	end

	-- [[ Credit from the DroDa, Thank you! ]]

	-- Delete default windows cursor
	-- Bug: Cursor is visible if you press ESC
	function PLUGIN:Think()
		local hover_panel = vgui.GetHoveredPanel()
		if !IsValid(hover_panel) then return end

		hover_panel:SetCursor("blank")
	end
end