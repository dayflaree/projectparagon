function Schema:BuildBusinessMenu()
    return false
end

function Schema:ShouldDrawCrosshair()
    return false
end

function Schema:CanDrawAmmoHUD()
    return false
end

function Schema:OnSpawnMenuOpen()
    if not LocalPlayer():GetCharacter():HasFlags("S") then
        return false
    end
end

function Schema:ContextMenuOpen()
    if not LocalPlayer():GetCharacter():HasFlags("s") then
        return false
    end
end

local scrW, scrH = ScrW(), ScrH()
function Schema:HUDPaintBackground()
    local ply, char = LocalPlayer(), LocalPlayer():GetCharacter()
    
    if ( IsValid(ix.gui.characterMenu) and not ix.gui.characterMenu:IsClosing() ) then return end
    if not ( IsValid(ply) and char ) then return end

    draw.DrawText(Schema.name.."", "Font-Elements-ScreenScale12", scrW / 2, ScreenScale(4), ColorAlpha(ix.config.Get("color"), 150), TEXT_ALIGN_CENTER)
    draw.DrawText("Everything you see may be subject to change!", "Font-Elements-Italic-ScreenScale8", scrW / 2, ScreenScale(14), ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
end