/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local SCENE = ix.meta.scenes

function SCENE:SetStartPos(pos)
    self.startpos = pos
end

function SCENE:SetStartAng(ang)
    self.startang = ang
end

function SCENE:SetStartFOV(fov)
    self.startfov = fov
end

function SCENE:SetEndPos(pos)
    self.endpos = pos
end

function SCENE:SetEndAng(ang)
    self.endang = ang
end

function SCENE:SetEndFOV(fov)
    self.endfov = fov
end

function SCENE:SetTime(time)
    self.time = time
end

function SCENE:SetFadeInTime(fadeintime)
    self.fadeintime = fadeintime
end

function SCENE:SetFadeOutTime(fadeouttime)
    self.fadeouttime = fadeouttime
end

function SCENE:SetHidePlayers(hideplayers)
    self.hideplayers = hideplayers
end

function SCENE:AddOnFinish(callback)
    self.callbacks = self.callbacks or {}
    table.insert(self.callbacks, callback)
end

function SCENE:GetDefault()
    return {
        ["startpos"] = Vector(0, 0, 0),
        ["startang"] = Angle(0, 0, 0),
        ["startfov"] = 75,
        ["endpos"] = Vector(0, 0, 0),
        ["endang"] = Angle(0, 0, 0),
        ["endfov"] = 75,
        ["time"] = 1,
        ["fadeintime"] = 0.5,
        ["fadeouttime"] = 0.5,
        ["hideplayers"] = true
    }
end

function SCENE:GetStartPos()
    return self.startpos or self:GetDefault().startpos
end

function SCENE:GetStartAng()
    return self.startang or self:GetDefault().startang
end

function SCENE:GetStartFOV()
    return self.startfov or self:GetDefault().startfov
end

function SCENE:GetEndPos()
    return self.endpos or self:GetDefault().endpos
end

function SCENE:GetEndAng()
    return self.endang or self:GetDefault().endang
end

function SCENE:GetEndFOV()
    return self.endfov or self:GetDefault().endfov
end

function SCENE:GetTime()
    return self.time or self:GetDefault().time
end

function SCENE:GetFadeInTime()
    return self.fadeintime or self:GetDefault().fadeintime
end

function SCENE:GetFadeOutTime()
    return self.fadeouttime or self:GetDefault().fadeouttime
end

function SCENE:GetHidePlayers()
    return self.hideplayers or self:GetDefault().hideplayers
end

function SCENE:GetTable()
    local tbl = {}

    for k, v in pairs(self) do
        tbl[k] = v
    end

    return tbl
end

function SCENE:GetCallbacks()
    return self.callbacks or {}
end

function SCENE:Play()
    PLUGIN.scenes:Play(self)
end