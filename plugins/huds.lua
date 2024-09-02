local PLUGIN = PLUGIN

PLUGIN.name = "Heads Up Displays"
PLUGIN.description = "Contains all heads up displays."
PLUGIN.author = "pkz.0z"

-- This might be a lil bit messy but I'm adding more shit in to it. Any code that looks a lil bit silly I will fix up!!! Do not touch unless I've made a retarded error 
-- edit: raaaa i can already see this shits ordered bad but fuck it idk how to reorder it


if not ( CLIENT ) then return end

surface.CreateFont("NTFHudFont", {
    font = "Arial",
    size = 25,
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

    return Color(r, g, b)
end

function PLUGIN:ShouldHideBars()
    return true
end

function PLUGIN:DrawGenHud(ply)

end

function PLUGIN:DrawNTFHud(ply, gall)
    if not ply:Alive() then return end

    for i, v in ipairs(player.GetAll()) do
        if v:IsE11() then
            local gap = 0
            for k, entity in ipairs(ents.GetAll()) do
                if IsValid(entity) and entity:IsPlayer() and entity:IsE11() then
                    local color = self:ReturnHPC(entity:Health())

                    local x = ScrW() - 285
                    local y = 10 + gap
                    local width = 280
                    local height = 30

                    surface.SetDrawColor(131, 131, 131, 66)
                    surface.DrawRect(x, y, width, height)
                    surface.DrawOutlinedRect(x, y, width, height, 1)
                    draw.DrawText(entity:Nick(), "NTFHudFont", ScrW() - 15, y + 3, color, TEXT_ALIGN_RIGHT)

                    gap = gap + 30
                end
            end
            break
        end
    end
end

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    local char = ply:GetCharacter()

    if not ( IsValid(ply) and char and ply:Alive() ) then return end

    PLUGIN:DrawGenHud(ply)

    if ply:IsE11() then
        self:DrawNTFHud(ply, v)
    end
end