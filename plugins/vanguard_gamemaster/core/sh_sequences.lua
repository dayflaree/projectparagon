/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.sequences = {}

function PLUGIN:RegisterSequence(name, data)
    self.sequences[name] = data
end

function PLUGIN:GetSequences()
    return self.sequences
end

function PLUGIN:RegisterSequences()
    self:RegisterSequence("screenshake", {
        name = "Screen Shake",
        description = "Shakes the screen.",
        sequence = {
            ["position"] = {
                name = "Position",
                description = "The position of the screen shake.",
                type = "vector",
                default = Vector(0, 0, 0)
            },
            ["amplitude"] = {
                name = "Amplitude",
                description = "The amplitude of the screen shake.",
                type = "number",
                default = 5
            },
            ["frequency"] = {
                name = "Frequency",
                description = "The frequency of the screen shake.",
                type = "number",
                default = 5
            },
            ["duration"] = {
                name = "Duration",
                description = "The duration of the screen shake.",
                type = "number",
                default = 10
            },
            ["radius"] = {
                name = "Radius",
                description = "The radius of the screen shake.",
                type = "number",
                default = 512
            }
        },
        callback = function(data)
            util.ScreenShake(data.position, data.amplitude, data.frequency, data.duration, data.radius)
        end
    })

    self:RegisterSequence("scene_play", {
        name = "Play Scene",
        description = "Plays a scene.",
        sequence = {
            ["startpos"] = {
                name = "Start Position",
                description = "The start position of the scene.",
                type = "vector",
                default = Vector(0, 0, 0)
            },
            ["startang"] = {
                name = "Start Angle",
                description = "The start angle of the scene.",
                type = "angle",
                default = Angle(0, 0, 0)
            },
            ["startfov"] = {
                name = "Start FOV",
                description = "The start FOV of the scene.",
                type = "number",
                default = 75
            },
            ["endpos"] = {
                name = "End Position",
                description = "The end position of the scene.",
                type = "vector",
                default = Vector(0, 0, 0)
            },
            ["endang"] = {
                name = "End Angle",
                description = "The end angle of the scene.",
                type = "angle",
                default = Angle(0, 0, 0)
            },
            ["endfov"] = {
                name = "End FOV",
                description = "The end FOV of the scene.",
                type = "number",
                default = 75
            },
            ["time"] = {
                name = "Time",
                description = "The time of the scene.",
                type = "number",
                default = 1
            },
            ["fadeintime"] = {
                name = "Fade In Time",
                description = "The fade in time of the scene.",
                type = "number",
                default = 0.5
            },
            ["fadeouttime"] = {
                name = "Fade Out Time",
                description = "The fade out time of the scene.",
                type = "number",
                default = 0.5
            },
            ["hideplayers"] = {
                name = "Hide Players",
                description = "Should players be hidden?",
                type = "boolean",
                default = true
            }
        },
        callback = function(data)
            local scene = self.scenes:Create()
            scene:SetStartPos(data.startpos)
            scene:SetStartAng(data.startang)
            scene:SetStartFOV(data.fov)
            scene:SetEndPos(data.endpos)
            scene:SetEndAng(data.endang)
            scene:SetEndFOV(data.fov)
            scene:SetTime(data.time)
            scene:SetFadeInTime(data.fadeintime)
            scene:SetFadeOutTime(data.fadeouttime)
            scene:SetHidePlayers(data.hideplayers)
            scene:Play()
        end
    })
end