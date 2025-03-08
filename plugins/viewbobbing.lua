local PLUGIN = PLUGIN

PLUGIN.name = "View Bobbing"
PLUGIN.description = "Adds realistic view bobbing effects and death camera"
PLUGIN.author = "Riggs, Enhanced by Claude"

ix.config.Add("viewBobbing", true, "Whether or not view bobbing should be enabled for everyone.", nil, {
    category = "Appearance",
})

ix.option.Add("smoothView", ix.type.bool, true, {
    category = "Appearance",
})

ix.lang.AddTable("english", {
    optSmoothView = "Smooth View",
    optdSmoothView = "Whether or not smooth mouse view should be enabled for yourself.",
})

if (SERVER) then
    -- Add server-side hook to remove death camera when player respawns
    hook.Add("PlayerSpawn", "ixViewBobbingCameraRemove", function(ply)
        ply:SendLua("if IsValid(LocalPlayer().ixDeathView) then LocalPlayer().ixDeathView:Remove() end")
    end)
    
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

-- Remove red death overlay
hook.Add("HUDShouldDraw", "RemoveRedDeathOverlay", function(name)
    if (name == "CHudDamageIndicator") then
        return false
    end
end)

-- Function to create client-side entity (replacement for CreateClientProp)
local function CreateDeathCamera(position, model, angles)
    local entity = ClientsideModel(model, RENDERGROUP_TRANSLUCENT)
    
    if IsValid(entity) then
        entity:SetPos(position)
        entity:SetAngles(angles or angle_zero)
        entity:SetNoDraw(true) -- Don't render the model itself
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
    
    return entity
end

-- Store eye position and angles for death camera
local cachedEyePos, cachedEyeAng
local yang
local xang

-- Listen for player death event
gameevent.Listen("entity_killed")
hook.Add("entity_killed", "ixViewBobbingDeathCamera", function(data)
    local ply = Entity(data.entindex_killed)
    
    if (ply == LocalPlayer() and ply:GetViewEntity() == ply) then
        -- Play death sound (optional)
        -- ply:EmitSound("death.ogg")
        
        -- Create a camera entity at player's eye position
        if cachedEyePos and cachedEyeAng then
            LocalPlayer().ixDeathView = CreateDeathCamera(cachedEyePos, "models/props_junk/PopCan01a.mdl", cachedEyeAng)
            if IsValid(LocalPlayer().ixDeathView) then
                LocalPlayer().ixDeathView.ShouldRemove = false
                LocalPlayer().ixDeathView.ShouldMove = true
            end
        end
    end
end)

-- Add motion blur on death
hook.Add("RenderScreenspaceEffects", "ixViewBobbingMotionBlur", function()
    if !LocalPlayer():Alive() and IsValid(LocalPlayer().ixDeathView) then
        DrawMotionBlur(0.15, 0.85, 0.04)
    end
end)

-- Update cached eye position and angles before drawing
hook.Add("PreDrawTranslucentRenderables", "ixViewBobbingEyeCache", function()
    if LocalPlayer():Alive() then
        cachedEyePos = EyePos()
        cachedEyeAng = EyeAngles()
    end
end)

-- Death camera management
hook.Add("Think", "ixViewBobbingDeathCamera", function()
    if IsValid(LocalPlayer().ixDeathView) then
        if LocalPlayer():Alive() then
            if LocalPlayer().ixDeathView.ShouldRemove then
                LocalPlayer().ixDeathView:Remove()
            end
        else
            -- Make the camera tilt upward (falling over effect)
            LocalPlayer().ixDeathView.AttemptToAngle = isnumber(LocalPlayer().ixDeathView.AttemptToAngle) and (LocalPlayer().ixDeathView.AttemptToAngle + 1) or 1
            LocalPlayer().ixDeathView.AttemptToPos = isnumber(LocalPlayer().ixDeathView.AttemptToPos) and (LocalPlayer().ixDeathView.AttemptToPos + 0.02) or 0.02
            
            if LocalPlayer().ixDeathView:GetAngles().p < 85 then
                LocalPlayer().ixDeathView:SetAngles(LocalPlayer().ixDeathView:GetAngles() + Angle(0.35, 0, 0))
            elseif !LocalPlayer().ixDeathView.ShouldMove then
                LocalPlayer().ixDeathView:SetAngles(LocalPlayer().ixDeathView:GetAngles() - Angle(0.35, 0, 0))
            end
            
            -- Move camera downward until hitting the ground
            local angle = LocalPlayer().ixDeathView:GetAngles()
            angle.p = 0
            local tr = util.QuickTrace(LocalPlayer().ixDeathView:GetPos(), 
                Vector(0, 0, -LocalPlayer().ixDeathView.AttemptToPos) + angle:Forward(), 
                {LocalPlayer().ixDeathView, LocalPlayer()})
                
            if !tr.HitWorld then
                if LocalPlayer().ixDeathView.ShouldMove then
                    LocalPlayer().ixDeathView:SetPos(tr.HitPos)
                end
            else
                if LocalPlayer().ixDeathView.ShouldMove then
                    LocalPlayer().ixDeathView:SetPos(tr.HitPos + tr.HitNormal * 10)
                    LocalPlayer().ixDeathView.ShouldMove = false
                    LocalPlayer().ixDeathView.ShouldRemove = true
                end
            end
        end
    end
end)

function PLUGIN:InputMouseApply(cmd, x, y, ang)
    -- Handle mouse input for death camera
    if IsValid(LocalPlayer().ixDeathView) then
        local test = LocalPlayer().ixDeathView:GetAngles() + Angle(y * 0.01, x * -0.01, 0)
        if test.p > 85 or test.p < -20 then return true end
        LocalPlayer().ixDeathView:SetAngles(test)
        return true
    end

    -- Check for view bobbing setting, respecting ViewConfig plugin's force settings
    local shouldEnableSmooth = ix.config.Get("viewBobbing", true) and ix.option.Get("smoothView", true)
    
    if not shouldEnableSmooth then
        return
    end

    if not (xang) then
        xang = x
    end

    if not (yang) then
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
    -- Use death camera if available
    if IsValid(LocalPlayer().ixDeathView) then
        local view = {
            origin = LocalPlayer().ixDeathView:GetPos(),
            angles = LocalPlayer().ixDeathView:GetAngles()
        }
        return view
    end

    if not (ix.config.Get("viewBobbing", true)) then
        return
    end

    if (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() and ix.gui.characterMenu:IsVisible()) then
        return
    end

    if (IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview()) then
        return
    end

    if (ply:InVehicle()) then
        return
    end

    local view = GAMEMODE.BaseClass:CalcView(ply, origin, angles, fov)

    if not (lerpRoll) then
        lerpRoll = view.angles.r
    end

    if not (lerpZ) then
        lerpZ = view.origin.z
    end

    if not (ply:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() and ply:Alive()) then
        local velocity = ply:GetVelocity()
        local intensity = 1

        local maxHealth = ply:GetMaxHealth()
        local health = ply:Health()
        
        if (health < maxHealth) then
            intensity = math.Clamp(1 * (maxHealth / health) * 0.75, 1, 3)
        end

        if (ply:GetMoveType() != MOVETYPE_NOCLIP) then
            if (ply:IsOnGround()) then
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
    -- Skip viewmodel rendering when using death camera
    if IsValid(LocalPlayer().ixDeathView) then
        return
    end

    if not (ix.config.Get("viewBobbing", true)) then
        return
    end

    if (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() and ix.gui.characterMenu:IsVisible()) then
        return
    end

    if (IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview()) then
        return
    end

    if (LocalPlayer():InVehicle()) then
        return
    end

    local origin, angles = GAMEMODE.BaseClass:CalcViewModelView(wep, vm, oldOrigin, oldAngles, origin, angles)

    if not (lerpRoll) then
        lerpRoll = angles.r
    end

    if not (lerpZ) then
        lerpZ = origin.z
    end

    if not (LocalPlayer():CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() and LocalPlayer():Alive()) then
        local velocity = LocalPlayer():GetVelocity()
        local intensity = 1

        local maxHealth = LocalPlayer():GetMaxHealth()
        local health = LocalPlayer():Health()
        
        if (health < maxHealth) then
            intensity = math.Clamp(1 * (maxHealth / health) * 0.75, 1, 3)
        end

        if (LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP) then
            if (LocalPlayer():IsOnGround()) then
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