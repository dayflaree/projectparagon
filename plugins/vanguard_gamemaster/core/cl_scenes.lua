/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.scenes = PLUGIN.scenes or {}

local SCENE = ix.meta.scenes or {}
SCENE.__index = SCENE

ix.meta.scenes = SCENE

function PLUGIN.scenes:Create()
    local scene = {}

    for k, v in pairs(SCENE) do
        scene[k] = v
    end

    return scene
end

function PLUGIN.scenes:Play(scene)
    if ( !scene ) then return end

    local startPos = scene:GetStartPos()
    local startAng = scene:GetStartAng()
    local startFOV = scene:GetStartFOV()
    local endPos = scene:GetEndPos()
    local endAng = scene:GetEndAng()
    local endFOV = scene:GetEndFOV()

    local fadeTimeIn = scene:GetFadeInTime()
    local fadeTimeOut = scene:GetFadeOutTime()

    local lerpPos = startPos
    local lerpAng = startAng
    local lerpFOV = startFOV

    local lastPosAdd = 0
    local lastAngAdd = 0
    local lastFOVAdd = 0

    local time = scene:GetTime()
    local startTime = CurTime()
    local endTime = startTime + time

    hook.Remove("CalcView", "Vanguard.Gamemaster.Scenes.CalcView")
    hook.Remove("ShouldDrawLocalPlayer", "Vanguard.Gamemaster.Scenes.ShouldDrawLocalPlayer")
    hook.Remove("Think", "Vanguard.Gamemaster.Scenes.Think")

    hook.Add("CalcView", "Vanguard.Gamemaster.Scenes.CalcView", function(ply, pos, ang, fov)
        if ( CurTime() >= endTime ) then
            hook.Remove("CalcView", "Vanguard.Gamemaster.Scenes.CalcView")

            return
        end

        local ft = FrameTime()

        lastPosAdd = lastPosAdd + ft / time
        lastAngAdd = lastAngAdd + ft / time
        lastFOVAdd = lastFOVAdd + ft / time

        lerpPos = LerpVector(lastPosAdd, startPos, endPos)
        lerpAng = LerpAngle(lastAngAdd, startAng, endAng)
        lerpFOV = Lerp(lastFOVAdd, startFOV, endFOV)

        local view = {}
        view.origin = lerpPos
        view.angles = lerpAng
        view.fov = lerpFOV
        view.drawviewer = true

        return view
    end)

    hook.Add("ShouldDrawLocalPlayer", "Vanguard.Gamemaster.Scenes.ShouldDrawLocalPlayer", function()
        if ( CurTime() >= endTime ) then
            hook.Remove("ShouldDrawLocalPlayer", "Vanguard.Gamemaster.Scenes.ShouldDrawLocalPlayer")

            return
        end

        return scene:GetHidePlayers()
    end)

    local playedFadeIn = false
    local playedFadeOut = false

    hook.Add("Think", "Vanguard.Gamemaster.Scenes.Think", function()
        if ( CurTime() >= endTime - 0.1 ) then
            hook.Remove("Think", "Vanguard.Gamemaster.Scenes.Think")

            self:OnFinish(scene)

            return
        end

        if ( !playedFadeIn ) then
            LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, fadeTimeIn, 0)
            playedFadeIn = true
        end

        if ( CurTime() >= endTime - scene:GetFadeOutTime() and !playedFadeOut ) then
            LocalPlayer():ScreenFade(SCREENFADE.OUT, color_black, fadeTimeOut, 0)
            playedFadeOut = true
        end
    end)

    LocalPlayer().scenesPlaying = true
end

function PLUGIN.scenes:OnFinish(scene)
    if ( !scene ) then return end

    local callbacks = scene:GetCallbacks()
    if ( callbacks ) then
        for k, v in pairs(callbacks) do
            v(scene)
        end
    end

    LocalPlayer().scenesPlaying = nil

    hook.Run("Vanguard.Gamemaster.Scenes.OnFinish", scene)
end

function PLUGIN.scenes:Cancel()
    hook.Remove("CalcView", "Vanguard.Gamemaster.Scenes.CalcView")
    hook.Remove("ShouldDrawLocalPlayer", "Vanguard.Gamemaster.Scenes.ShouldDrawLocalPlayer")
    hook.Remove("Think", "Vanguard.Gamemaster.Scenes.Think")
end

concommand.Add("vanguard_gamemaster_scene_example", function(ply, cmd, args)
    local time = tonumber(args[1]) or 5
    
    local scene = PLUGIN.scenes:Create()
    scene:SetStartPos(EyePos())
    scene:SetStartAng(ply:EyeAngles())
    scene:SetStartFOV(100)
    scene:SetEndPos(EyePos() - ply:EyeAngles():Forward() * 100 + Vector(0, 0, 50))
    scene:SetEndAng(ply:EyeAngles() + Angle(10, 0, 0))
    scene:SetEndFOV(75)
    scene:SetTime(time)
    scene:SetFadeInTime(1)
    scene:SetFadeOutTime(0)
    scene:SetHidePlayers(false)
    scene:Play()
    
    local anotherScene = PLUGIN.scenes:Create()
    anotherScene:SetStartPos(EyePos() - ply:EyeAngles():Forward() * 100 + Vector(0, 0, 50))
    anotherScene:SetStartAng(ply:EyeAngles() + Angle(10, 0, 0))
    anotherScene:SetStartFOV(75)
    anotherScene:SetEndPos(EyePos())
    anotherScene:SetEndAng(ply:EyeAngles())
    anotherScene:SetEndFOV(100)
    anotherScene:SetTime(time)
    anotherScene:SetFadeInTime(0)
    anotherScene:SetFadeOutTime(1)
    anotherScene:SetHidePlayers(true)

    scene:AddOnFinish(function()
        anotherScene:Play()
    end)
end)

concommand.Add("vanguard_gamemaster_scene_cancel", function(ply, cmd, args)
    PLUGIN.scenes:Cancel()
end)

net.Receive("Vanguard.Gamemaster.Scenes.Play", function()
    local data = net.ReadTable()

    local scene = PLUGIN.scenes:Create()
    scene:SetStartPos(data.startpos)
    scene:SetStartAng(data.startang)
    scene:SetStartFOV(data.startfov)
    scene:SetEndPos(data.endpos)
    scene:SetEndAng(data.endang)
    scene:SetEndFOV(data.endfov)
    scene:SetTime(data.time)
    scene:SetFadeInTime(data.fadeintime)
    scene:SetFadeOutTime(data.fadeouttime)
    scene:SetHidePlayers(data.hideplayers)
    scene:Play()
end)