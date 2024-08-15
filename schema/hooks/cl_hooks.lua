-- Here is where all clientside hooks should go.

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

function Schema:GetArmorText(ply)
    if ( ply:Armor() >= 100 ) then
        return "Wearing Premium Quality Armor", Color(0, 0, 255)
    elseif ( ply:Armor() >= 75 ) then
        return "Wearing High Quality Armor", Color(50, 50, 255)
    elseif ( ply:Armor() >= 50 ) then
        return "Wearing Medium Quality Armor", Color(100, 100, 255)
    elseif ( ply:Armor() >= 25 ) then
        return "Wearing Low Quality Armor", Color(150, 150, 255)
    elseif ( ply:Armor() >= 10 ) then
        return "Wearing Cheap Quality Armor", Color(200, 200, 255)
    else
        return "", color_white
    end
end

function Schema:GetInjuredText(ply)
    if ( ply:Health() >= 100 ) then
        return "Perfectly Healthy", Color(0, 255, 0)
    elseif ( ply:Health() >= 99 ) then
        return "Healthy", Color(50, 200, 0)
    elseif ( ply:Health() >= 98 ) then
        return "Scarred", Color(75, 200, 0)
    elseif ( ply:Health() >= 95 ) then
        return "Slightly Grazed", Color(90, 200, 0)
    elseif ( ply:Health() >= 90 ) then
        return "Moderately Grazed", Color(100, 200, 0)
    elseif ( ply:Health() >= 85 ) then
        return "Majorly Grazed", Color(110, 200, 0)
    elseif ( ply:Health() >= 80 ) then
        return "Slightly Injured", Color(120, 190, 0)
    elseif ( ply:Health() >= 70 ) then
        return "Moderately Injured", Color(150, 170, 0)
    elseif ( ply:Health() >= 65 ) then
        return "Majorly Injured", Color(170, 150, 0)
    elseif ( ply:Health() >= 60 ) then
        return "Marginally Wounded", Color(170, 100, 0)
    elseif ( ply:Health() >= 50 ) then
        return "Moderately Wounded", Color(190, 90, 0)
    elseif ( ply:Health() >= 45 ) then
        return "Majorly Wounded", Color(200, 70, 0)
    elseif ( ply:Health() >= 40 ) then
        return "Seriously Wounded", Color(200, 60, 0)
    elseif ( ply:Health() >= 35 ) then
        return "Fatally Wounded", Color(200, 50, 0)
    elseif ( ply:Health() >= 30 ) then
        return "Mortally Wounded", Color(200, 40, 0)
    elseif ( ply:Health() >= 20 ) then
        return "Bleeding Out", Color(200, 30, 0)
    elseif ( ply:Health() >= 15 ) then
        return "Seriously Bleeding Out", Color(200, 20, 0)
    elseif ( ply:Health() >= 10 ) then
        return "Cardiac Arrest", Color(200, 10, 0)
    elseif ( ply:Health() >= 5 ) then
        return "Visibly Dying", Color(200, 0, 0)
    elseif ( ply:Health() >= 1 ) then
        return "No Pulse Response", Color(255, 0, 0)
    elseif ( ply:Health() >= 0 ) then
        return "Deceased", Color(0, 0, 0)
    else
        return "", color_white
    end
end

function Schema:BuildBusinessMenu()
    return false
end

function Schema:ShouldDrawCrosshair()
    return false
end

function Schema:CanDrawAmmoHUD()
    return false
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
