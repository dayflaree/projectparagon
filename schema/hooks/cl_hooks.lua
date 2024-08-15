-- Here is where all clientside hooks should go.

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

    if ( ply:Alive() ) then
        local maxHealth = ply:GetMaxHealth()
        local health = ply:Health()
        
        if ( health < maxHealth ) then
            self:DrawPlayerScreenDamage(ply, 1 - ((1 / maxHealth) * health))
        end
    else
        return
    end
    
    if ( ix.config.Get("vignette", true) ) then
        self:DrawPlayerVignette()
    end

    draw.DrawText(Schema.name.."", "Font-Elements-ScreenScale12", scrW / 2, ScreenScale(4), ColorAlpha(ix.config.Get("color"), 150), TEXT_ALIGN_CENTER)
    draw.DrawText("Everything you see may be subject to change!", "Font-Elements-Italic-ScreenScale8", scrW / 2, ScreenScale(14), ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
end

local damageOverlay = ix.util.GetMaterial("helix/gui/vignette.png")
local vignette1 = ix.util.GetMaterial("helix/gui/vignette.png")
local vignette2 = ix.util.GetMaterial("helix/gui/vignette.png")

function Schema:DrawPlayerScreenDamage(ply, damageFraction)
    surface.SetDrawColor(255, 0, 0, math.Clamp(255 * damageFraction, 0, 255))
    surface.SetMaterial(vignette2)
    surface.DrawTexturedRect(0, 0, scrW, scrH)

    surface.SetDrawColor(255, 0, 0, math.Clamp(255 * damageFraction, 0, 255))
    surface.SetMaterial(damageOverlay)
    surface.DrawTexturedRect(0, 0, scrW, scrH)
end

function Schema:DrawPlayerVignette()
    surface.SetDrawColor(0, 0, 0, 150)
    surface.SetMaterial(vignette1)
    surface.DrawTexturedRect(0, 0, scrW, scrH)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.SetMaterial(vignette2)
    surface.DrawTexturedRect(0, 0, scrW, scrH)
end
