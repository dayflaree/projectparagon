local PLUGIN = PLUGIN

PLUGIN.name = "Proximity Enhancements"
PLUGIN.description = "Adds enhancements to the proximity chat system."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("proximityEnhancements", true, "Whether or not to enable proximity enhancements.", nil, {
    category = "proximityEnhancements"
})

ix.config.Add("proximityMuteVolume", 10, "The volume to set when a player is muted.", nil, {
    data = {min = 0, max = 100},
    category = "proximityEnhancements"
})

ix.config.Add("proximityMaxTraces", 8, "The number of traces to use for wall thickness calculations.", nil, {
    data = {min = 1, max = 16},
    category = "proximityEnhancements"
})

ix.config.Add("proximityMaxDistance", 1000, "The maximum distance for full volume reduction.", nil, {
    data = {min = 0, max = 10000},
    category = "proximityEnhancements"
})

ix.config.Add("proximityMaxVolume", 1, "The maximum volume level.", nil, {
    data = {min = 0, max = 1},
    category = "proximityEnhancements"
})

ix.lang.AddTable("english", {
    proximityEnhancements = "Proximity Enhancements",
    muteVolume = "Mute Volume",
})

if ( SERVER ) then return end

-- Function to calculate wall thickness and adjust sound volume
local function CalculateVoiceVolume(listener, speaker)
    local maxTraces = ix.config.Get("proximityMaxTraces", 8)
    local maxDistance = ix.config.Get("proximityMaxDistance", 500)
    local maxVolume = ix.config.Get("proximityMaxVolume", 1)

    local totalVolume = 0
    
    -- Trace from the listener to the speaker
    local trace = util.TraceLine({
        start = listener:EyePos(),
        endpos = speaker:EyePos(),
        filter = {listener, speaker}
    })

    debugoverlay.Line(listener:EyePos(), speaker:EyePos(), 0.1, Color(255, 0, 0))

    for i = 1, maxTraces do
        -- Calculate the offset for the trace
        local offset = VectorRand() * 16

        -- Trace from the listener to the speaker with the offset
        local trace = util.TraceLine({
            start = listener:EyePos(),
            endpos = speaker:EyePos() + offset,
            filter = {listener, speaker}
        })

        -- Calculate the volume reduction based on the thickness of the wall
        if ( trace.Hit and trace.HitWorld ) then
            local volume = 1 - ( trace.Fraction * 0.5 )
            totalVolume = totalVolume + volume
            debugoverlay.Line(listener:EyePos(), trace.HitPos, 0.1, Color(255, 0, 0))
        else
            totalVolume = totalVolume + 1
        end

        debugoverlay.Line(listener:EyePos(), trace.HitPos, 0.1, Color(0, 255, 0))
    end

    -- Calculate the distance factor
    local distanceFactor = 1 - ( listener:EyePos():Distance(speaker:EyePos()) / maxDistance )
    distanceFactor = math.Clamp(distanceFactor, 0, 1)

    -- Average volume from successful traces
    local averageVolume = ( totalVolume / maxTraces ) * distanceFactor

    -- If the speaker is in a vehicle, reduce volume by 10%
    if ( speaker:InVehicle() ) then
        averageVolume = averageVolume * 0.9
    end

    -- If the listener is in a vehicle and not in the same vehicle as the speaker, reduce volume by 20%
    if ( listener:InVehicle() and listener:GetVehicle() != speaker:GetVehicle() ) then
        averageVolume = averageVolume * 0.8
    end

    debugoverlay.Text(listener:EyePos(), string.format("Volume: %.2f", averageVolume), 0.1)
    
    -- Return the final calculated volume
    return averageVolume
end

local nextThink = 0
function PLUGIN:Think()
    if ( CurTime() < nextThink ) then return end
    nextThink = CurTime() + 0.1

    if ( !ix.config.Get("proximityEnhancements", true) ) then return end

    local listener = LocalPlayer()
    if ( !IsValid(listener) ) then return end

    for _, talker in player.Iterator() do
        if ( talker == listener ) then continue end

        local volume = CalculateVoiceVolume(talker, listener) or 0
        talker:SetVoiceVolumeScale(volume)
    end
end