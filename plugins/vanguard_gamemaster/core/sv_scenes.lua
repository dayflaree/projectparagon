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

    local tbl = {}
    
    tbl.startpos = scene:GetStartPos()
    tbl.startang = scene:GetStartAng()
    tbl.startfov = scene:GetStartFOV()
    tbl.endpos = scene:GetEndPos()
    tbl.endang = scene:GetEndAng()
    tbl.endfov = scene:GetEndFOV()
    tbl.time = scene:GetTime()
    tbl.fadeintime = scene:GetFadeInTime()
    tbl.fadeouttime = scene:GetFadeOutTime()
    tbl.hideplayers = scene:GetHidePlayers()

    net.Start("Vanguard.Gamemaster.Scenes.Play")
        net.WriteTable(tbl)
    net.Broadcast()

    local time = scene:GetTime()
    local startTime = CurTime()
    local endTime = startTime + time

    hook.Add("SetupPlayerVisibility", "Vanguard.Gamemaster.Scenes.SetupPlayerVisibility", function(ply, viewEntity)
        if ( CurTime() >= endTime ) then
            hook.Remove("SetupPlayerVisibility", "Vanguard.Gamemaster.Scenes.SetupPlayerVisibility")

            return
        end

        AddOriginToPVS(scene:GetStartPos())
        AddOriginToPVS(scene:GetEndPos())
    end)

    hook.Add("Think", "Vanguard.Gamemaster.Scenes.Think", function()
        if ( CurTime() >= endTime - 0.1 ) then
            hook.Remove("Think", "Vanguard.Gamemaster.Scenes.Think")

            self:OnFinish(scene)

            return
        end
    end)

    for k, v in player.Iterator() do
        v:SetNetVar("scenesPlaying", true)
    end
end

function PLUGIN.scenes:OnFinish(scene)
    if ( !scene ) then return end

    local callbacks = scene:GetCallbacks()
    if ( callbacks ) then
        for k, v in pairs(callbacks) do
            v(scene)
        end
    end

    for k, v in player.Iterator() do
        v:SetNetVar("scenesPlaying")
    end

    hook.Run("Vanguard.Gamemaster.Scenes.OnFinish", scene)
end

function PLUGIN.scenes:Cancel()
    hook.Remove("CalcView", "Vanguard.Gamemaster.Scenes.CalcView")
    hook.Remove("ShouldDrawLocalPlayer", "Vanguard.Gamemaster.Scenes.ShouldDrawLocalPlayer")
    hook.Remove("SetupPlayerVisibility", "Vanguard.Gamemaster.Scenes.SetupPlayerVisibility")
    hook.Remove("Think", "Vanguard.Gamemaster.Scenes.Think")
end

util.AddNetworkString("Vanguard.Gamemaster.Scenes.Play")
util.AddNetworkString("Vanguard.Gamemaster.Scenes.Remove")

concommand.Add("vanguard_gamemaster_scene_example_server", function(ply, cmd, args)
    if ( !ply:IsSuperAdmin() ) then return end

    local time = tonumber(args[1]) or 5
    
    local scene = PLUGIN.scenes:Create()
    scene:SetStartPos(ply:EyePos())
    scene:SetStartAng(ply:EyeAngles())
    scene:SetStartFOV(100)
    scene:SetEndPos(ply:EyePos() - ply:EyeAngles():Forward() * 100 + Vector(0, 0, 50))
    scene:SetEndAng(ply:EyeAngles() + Angle(10, 0, 0))
    scene:SetEndFOV(75)
    scene:SetTime(time)
    scene:SetFadeInTime(1)
    scene:SetFadeOutTime(0)
    scene:SetHidePlayers(false)
    scene:Play()
    
    local anotherScene = PLUGIN.scenes:Create()
    anotherScene:SetStartPos(ply:EyePos() - ply:EyeAngles():Forward() * 100 + Vector(0, 0, 50))
    anotherScene:SetStartAng(ply:EyeAngles() + Angle(10, 0, 0))
    anotherScene:SetStartFOV(75)
    anotherScene:SetEndPos(ply:EyePos())
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