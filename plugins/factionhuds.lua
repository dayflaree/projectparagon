local PLUGIN = PLUGIN

PLUGIN.name = "Heads Up Displays"
PLUGIN.description = "Contains all heads up displays."
PLUGIN.author = "pkz.0z"

PLUGIN.HUDScale = 1.0

if not ( CLIENT ) then return end

surface.CreateFont("NTFHudFont", {
    font = "Courier New",
    size = 22 * PLUGIN.HUDScale,
    extended = true,
    shadow = true,
    weight = 100
})

function PLUGIN:ReturnHPC(hp)
    hp = math.Clamp(hp, 0, 100)

    local r, g, b

    if hp == 100 then
        r, g, b = 255, 255, 255
    elseif hp >= 75 then
        local t = (hp - 75) / 25
        r = 255
        g = 200 + math.floor(55 * t)
        b = 200 + math.floor(55 * t)
    elseif hp >= 35 then
        local t = (hp - 35) / 40
        r = 255
        g = math.floor(200 * t)
        b = math.floor(200 * t)
    elseif hp >= 10 then
        local t = (hp - 10) / 25
        r = 150 + math.floor(105 * t)
        g = 0
        b = 0
    else
        r, g, b = 0, 0, 0
    end

    return Color(r, g, b, 200)
end

function PLUGIN:ShouldHideBars()
    return true
end

function PLUGIN:DrawGenHud(ply)
end

function PLUGIN:DrawNTFHud(ply, gall)
    if !ply:Alive() then return end

    local gap = 0
    for i, v in player.Iterator() do
        if !v:IsMTF() then continue end

        local color = self:ReturnHPC(v:Health())

        local x = (ScrW() - 320 * PLUGIN.HUDScale)
        local y = (10 + gap) * PLUGIN.HUDScale
        local width = 310 * PLUGIN.HUDScale
        local height = 30 * PLUGIN.HUDScale

        surface.SetDrawColor(color)
        surface.SetMaterial(Material("projectparagon/paragon/scoreboard.png"))
        surface.DrawTexturedRect(x, y, width, height)

        local textHeight = draw.GetFontHeight("NTFHudFont")

        local textY = y + (height - textHeight) / 2

        draw.DrawText(v:Nick(), "NTFHudFont", x + width / 2, textY, color_white, TEXT_ALIGN_CENTER)

        gap = gap + 32
    end
end


function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    local char = ply:GetCharacter()

    if not ( IsValid(ply) and char and ply:Alive() ) then return end

    PLUGIN:DrawGenHud(ply)

    if ply:IsMTF() then
        self:DrawNTFHud(ply, v)
    end
end
