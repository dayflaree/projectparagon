local PLUGIN = PLUGIN

PLUGIN.name = "View Bobbing"
PLUGIN.description = ""
PLUGIN.author = "Reece™"

ix.config.Add("viewBobbing", true, "Wether or not view bobbing should be enabled for everyone.", nil, {
    category = "Appearance",
})

ix.option.Add("smoothView", ix.type.bool, true, {
    category = "Appearance",
})

ix.lang.AddTable("english", {
    optSmoothView = "Smooth View",
    optdSmoothView = "Wether or not smooth mouse view should be enabled for yourself.",
})

if ( SERVER ) then
    return
end

local playerMeta = FindMetaTable("Player")

local function isAllowed()
    return ix.config.Get("thirdperson")
end

function playerMeta:CanOverrideView()
    local entity = Entity(self:GetLocalVar("ragdoll", 0))

    if (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() and ix.gui.characterMenu:IsVisible()) then
        return false
    end

    if (IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview()) then
        return false
    end

    if (ix.option.Get("thirdpersonEnabled", false) and
        !IsValid(self:GetVehicle()) and
        isAllowed() and
        IsValid(self) and
        self:GetCharacter() and
        !self:GetNetVar("actEnterAngle") and
        !IsValid(entity) and
        LocalPlayer():Alive()
        ) then
        return true
    end
end

local yang
local xang
function PLUGIN:InputMouseApply(cmd, x, y, ang)
    if not ( ix.config.Get("viewBobbing", true) ) then
        return
    end

    if not ( ix.option.Get("smoothView", true) ) then
        return
    end

    if not ( xang ) then
        xang = x
    end

    if not ( yang ) then
        yang = y
    end

    xang = Lerp(0.03, xang, xang - x)
    yang = Lerp(0.03, yang, math.Clamp(yang - y, -89.99, 89.99))

    cmd:SetViewAngles(LerpAngle(0.05, ang, Angle(-yang, xang)))

    return true
end

local lerpFov = 90
local lerpRoll
local lerpZ
function PLUGIN:CalcView(ply, origin, angles, fov)
    if not ( ix.config.Get("viewBobbing", true) ) then
        return
    end

    if ( IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() and ix.gui.characterMenu:IsVisible() ) then
        return
    end

    if ( IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview() ) then
        return
    end

    if ( ply:InVehicle() ) then
        return
    end

    local view = GAMEMODE.BaseClass:CalcView(ply, origin, angles, fov)

    if not ( lerpRoll ) then
        lerpRoll = view.angles.r
    end

    if not ( lerpZ ) then
        lerpZ = view.origin.z
    end

    if not ( ply:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() and ply:Alive() ) then
        local velocity = ply:GetVelocity()
        local intensity = 1

        local maxHealth = ply:GetMaxHealth()
        local health = ply:Health()
        
        if ( health < maxHealth ) then
            intensity = math.Clamp(1 * (maxHealth / health) * 0.75, 1, 3)
        end

        if ( ply:GetMoveType() != MOVETYPE_NOCLIP ) then
            if ( ply:IsOnGround() ) then
                lerpFov = Lerp(0.08, lerpFov, view.fov + math.sin(RealTime() * 0.5) * velocity:Length() * 0.005)
                lerpRoll = math.Round(Lerp(0.1, lerpRoll, view.angles.r + (math.sin(RealTime() * 8) * velocity:Length() * 0.01) * intensity), 2)
                lerpZ = math.Round(Lerp(0.5, lerpZ, view.origin.z + (math.sin(RealTime() * 16) * velocity:Length() * 0.005) * intensity), 2)
            else
                lerpFov = Lerp(0.1, lerpFov, fov - 10)
                lerpRoll = Lerp(0.1, lerpRoll, view.angles.r)
                lerpZ = Lerp(0.5, lerpZ, view.origin.z)
            end
        else
            lerpFov = view.fov
            lerpZ = view.origin.z
            lerpRoll = view.angles.r
        end

        view.fov = lerpFov
        view.origin.z = lerpZ
        view.angles.r = lerpRoll
        
        return view
    end
end

local lerpRoll
local lerpZ
function PLUGIN:CalcViewModelView(wep, vm, oldOrigin, oldAngles, origin, angles)
    if not ( ix.config.Get("viewBobbing", true) ) then
        return
    end

    if ( IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() and ix.gui.characterMenu:IsVisible() ) then
        return
    end

    if ( IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview() ) then
        return
    end

    if ( LocalPlayer():InVehicle() ) then
        return
    end

    local origin, angles = GAMEMODE.BaseClass:CalcViewModelView(wep, vm, oldOrigin, oldAngles, origin, angles)

    if not ( lerpRoll ) then
        lerpRoll = angles.r
    end

    if not ( lerpZ ) then
        lerpZ = origin.z
    end

    if not ( LocalPlayer():CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() and LocalPlayer():Alive() ) then
        local velocity = LocalPlayer():GetVelocity()
        local intensity = 1

        local maxHealth = LocalPlayer():GetMaxHealth()
        local health = LocalPlayer():Health()
        
        if ( health < maxHealth ) then
            intensity = math.Clamp(1 * (maxHealth / health) * 0.75, 1, 3)
        end

        if ( LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP ) then
            if ( LocalPlayer():IsOnGround() ) then
                lerpRoll = math.Round(Lerp(0.1, lerpRoll, angles.r + (math.sin(RealTime() * 8) * velocity:Length() * 0.01) * intensity), 2)
                lerpZ = math.Round(Lerp(0.5, lerpZ, origin.z + (math.sin(RealTime() * 16) * velocity:Length() * 0.005) * intensity), 2)
            else
                lerpRoll = Lerp(0.1, lerpRoll, angles.r)
                lerpZ = Lerp(0.5, lerpZ, origin.z)
            end
        else
            lerpZ = origin.z
            lerpRoll = angles.r
        end

        origin.z = lerpZ
        angles.r = lerpRoll
        
        return origin, angles
    end
end