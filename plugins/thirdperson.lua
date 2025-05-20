local PLUGIN = PLUGIN

PLUGIN.name = "Thirdperson"
PLUGIN.author = "Null"
PLUGIN.description = "Enables third person camera usage, with many extras than the original."

ix.config.Add("thirdperson", true, "Allow Thirdperson in the server.", nil, {
    category = "server"
})

ix.config.ForceSet("thirdperson", true)

ix.lang.AddTable("english", {
    optThirdpersonFOV = "Camera field of view",
    optThirdpersonSmoothPosition = "Enable smooth position third person",
    optThirdpersonSmoothAngle = "Enable smooth angle third person",
    optThirdpersonFollowHead = "Follow head origin",
    optFirstpersonEnabled = "Enable immersive first person",
})

if ( CLIENT ) then
    local function isHidden()
        return !ix.config.Get("thirdperson")
    end

    ix.option.Add("thirdpersonEnabled", ix.type.bool, false, {
        category = "thirdperson",
        hidden = isHidden,
        OnChanged = function(oldValue, value)
            hook.Run("ThirdPersonToggled", oldValue, value)
        end
    })

    ix.option.Add("thirdpersonVertical", ix.type.number, 0, {
        category = "thirdperson", min = 0, max = 30,
        hidden = isHidden
    })

    ix.option.Add("thirdpersonHorizontal", ix.type.number, 18, {
        category = "thirdperson", min = -30, max = 30,
        hidden = isHidden
    })

    ix.option.Add("thirdpersonDistance", ix.type.number, 35, {
        category = "thirdperson", min = 0, max = 100,
        hidden = isHidden
    })

    ix.option.Add("thirdpersonFOV", ix.type.number, 75, {
        category = "thirdperson", min = 50, max = 120,
        hidden = isHidden
    })

    ix.option.Add("thirdpersonSmoothPosition", ix.type.bool, true, {
        category = "thirdperson",
        hidden = isHidden
    })

    ix.option.Add("thirdpersonSmoothAngle", ix.type.bool, true, {
        category = "thirdperson",
        hidden = isHidden
    })

    ix.option.Add("thirdpersonFollowHead", ix.type.bool, false, {
        category = "thirdperson",
        hidden = isHidden
    })

    ix.option.Add("firstpersonEnabled", ix.type.bool, false, {
        category = "thirdperson",
        OnChanged = function(oldValue, value)
            hook.Run("FirstPersonToggled", oldValue, value)
        end
    })

    concommand.Add("ix_togglethirdperson", function()
        local bEnabled = !ix.option.Get("thirdpersonEnabled", false)

        ix.option.Set("thirdpersonEnabled", bEnabled)
    end)

    concommand.Add("ix_togglefirstperson", function()
        local bEnabled = !ix.option.Get("firstpersonEnabled", false)

        ix.option.Set("firstpersonEnabled", bEnabled)
    end)

    local function isAllowed()
        return ix.config.Get("thirdperson")
    end

    local playerMeta = FindMetaTable("Player")
    local traceMin = Vector(-4, -4, -4)
    local traceMax = Vector(4, 4, 4)

    function playerMeta:CanOverrideView()
        local localPlayer = LocalPlayer()
        local entity = Entity(self:GetLocalVar("ragdoll", 0))

        local charMenu = ix.gui.characterMenu
        if ( IsValid(charMenu) and !charMenu:IsClosing() and charMenu:IsVisible() ) then
            local charSettings = charMenu.settingsCharacterPanel
            if ( charSettings and charSettings.category and string.lower(charSettings.category) == "thirdperson" ) then
                return true
            end

            return false
        end

        if ( IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview() ) then
            return false
        end

        if ( SCENES_PLAYING ) then
            return false
        end

        if ( hook.Run("ShouldDrawThirdpersonView") == false ) then
            return false
        end

        if ( ix.option.Get("thirdpersonEnabled", false) and
            !IsValid(self:GetVehicle()) and
            isAllowed() and
            IsValid(self) and
            self:GetCharacter() and
            !self:GetNetVar("actEnterAngle") and
            self:GetMoveType() != MOVETYPE_NOCLIP and
            !IsValid(entity) and
            localPlayer:Alive() ) then
            return true
        end
    end

    function playerMeta:CanOverrideFirstView()
        local localPlayer = LocalPlayer()
        local entity = Entity(self:GetLocalVar("ragdoll", 0))

        local charMenu = ix.gui.characterMenu
        if ( IsValid(charMenu) and !charMenu:IsClosing() and charMenu:IsVisible() ) then
            return false
        end

        if ( IsValid(ix.gui.menu) and ix.gui.menu:GetCharacterOverview() ) then
            return false
        end

        if ( SCENES_PLAYING ) then
            return false
        end

        if ( hook.Run("ShouldDrawFirstpersonView") == false ) then
            return false
        end

        if ( ix.option.Get("firstpersonEnabled", false) and
            !IsValid(self:GetVehicle()) and
            isAllowed() and
            IsValid(self) and
            self:GetCharacter() and
            !self:GetNetVar("actEnterAngle") and
            self:GetMoveType() != MOVETYPE_NOCLIP and
            !IsValid(entity) and
            localPlayer:Alive() ) then
            return true
        end
    end

    local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng, owner
    local clmp = math.Clamp
    crouchFactor = 0

    local lerpOrigin
    local lerpAngles
    function PLUGIN:CalcView(ply, origin, angles, fov)
        local localPlayer = LocalPlayer()
        ft = FrameTime()

        if ( ply:CanOverrideView() and localPlayer:GetViewEntity() == localPlayer ) then
            local bNoclip = ply:GetMoveType() == MOVETYPE_NOCLIP
    
            if ( ( ply:OnGround() and ply:KeyDown(IN_DUCK) ) or ply:Crouching() ) then
                crouchFactor = Lerp(ft*5, crouchFactor, 1)
            else
                crouchFactor = Lerp(ft*5, crouchFactor, 0)
            end
    
            local headPos = ply:GetPos() + ply:GetViewOffset() - ply:GetViewOffsetDucked() * 0.5 * crouchFactor
            if ( ix.option.Get("thirdpersonFollowHead") ) then
                if ( ply:LookupBone("ValveBiped.Bip01_Head1") ) then
                    headPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
                elseif ( ply:LookupBone("ValveBiped.head") ) then
                    headPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.head"))
                end
            end

            curAng = ply:EyeAngles()
            view = {}
            traceData = {}
                traceData.start =     headPos +
                                    curAng:Up() * ix.option.Get("thirdpersonVertical", 20) +
                                    curAng:Right() * ix.option.Get("thirdpersonHorizontal", 5)
                traceData.endpos = traceData.start - curAng:Forward() * ix.option.Get("thirdpersonDistance", 75)
                traceData.filter = ply
                traceData.ignoreworld = bNoclip
                traceData.mins = traceMin
                traceData.maxs = traceMax

            local hitpos = util.TraceHull(traceData).HitPos

            if not ( lerpOrigin ) then
                lerpOrigin = hitpos
            end

            if not ( lerpAngles ) then
                lerpAngles = curAng
            end

            if ( ix.option.Get("thirdpersonSmoothPosition") ) then
                lerpOrigin = LerpVector(ft * 8, lerpOrigin, hitpos)
            else
                lerpOrigin = hitpos
            end

            if ( ix.option.Get("thirdpersonSmoothAngle") ) then
                lerpAngles = LerpAngle(ft * 8, lerpAngles, curAng)
            else
                lerpAngles = curAng
            end

            view.origin = lerpOrigin
            view.angles = lerpAngles
            view.fov = ix.option.Get("thirdpersonFOV")

            return view
        else
            lerpOrigin = origin
            lerpAngles = angles
            
            if ( ply:CanOverrideFirstView() ) then
                if not ( ply:LookupBone("ValveBiped.Bip01_Head1") ) then
                    return
                end
        
                local headBonePos = origin
                local matrix
                local headBoneAng
                if ( ply:LookupBone("ValveBiped.Bip01_Head1") ) then
                    headBonePos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
                    matrix = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Head1"))
                    headBoneAng = matrix:GetAngles()
                    headBonePos = headBonePos + headBoneAng:Forward() * 4 + headBoneAng:Right() * 6
                end
        
                return {
                    origin = headBonePos or origin,
                    angles = angles,
                    fov = fov,
                    drawviewer = true,
                }
            end
        end
    end

    function PLUGIN:CreateMove(cmd)
    end

    function PLUGIN:InputMouseApply(cmd, x, y, ang)
    end

    function PLUGIN:PlayerSwitchWeapon( ply, oldWeapon, newWeapon )
    end

    function PLUGIN:ShouldDrawThirdpersonView()
    end
    
    function PLUGIN:ShouldDrawFirstpersonView()
    end

    function PLUGIN:ShouldDrawLocalPlayer()
        local localPlayer = LocalPlayer()
        if ( localPlayer:GetViewEntity() == localPlayer and not IsValid(localPlayer:GetVehicle()) ) then
            return localPlayer:CanOverrideView()
        end
    end

    function PLUGIN:PrePlayerDraw(ply, flags)
        local localPlayer = LocalPlayer()
        if not ( localPlayer:CanOverrideView() ) then return end

        if ( ply == localPlayer ) then return end

        local trace = util.TraceHull({
            start = localPlayer:EyePos(),
            endpos = ply:EyePos(),
            mask = MASK_SHOT,
        })

        ply:DrawShadow(true)

        if ( ( trace and not IsValid(trace.Entity) and trace.Entity:IsPlayer() ) or not ply:IsLineOfSightClear(localPlayer) ) then
            ply:DrawShadow(false)
            return true
        end
    end
end