local PLUGIN = PLUGIN

PLUGIN.name = "Schedules"
PLUGIN.description = "Adds a schedule system."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2023 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
# Schedules
Schedules are a way to trigger events at specific times of the day. This plugin allows you to define schedules and have them trigger at specific times.

Keep in mind that it uses StormFox2's time system, so it will only work if StormFox2 is installed.

## Defining Schedules
Schedules are defined in the `schedules` table in the `sh_plugin.lua` file. The key is the time in 24-hour format and the value is a table with the following fields:
- `on` (number): The time the schedule should start.
- `off` (number): The time the schedule should end.
- `name` (string): The name of the schedule.
- `description` (string): A description of the schedule.
- `onStart` (function): The function to call when the schedule is triggered. This is server-side only.

## Defining Faction Schedules
You can define faction schedules by adding the same table but renaming 'PLUGIN' to 'FACTION' within the respective faction file. This will allow you to define schedules for specific factions. Same applies to classes. Just rename 'PLUGIN' to 'CLASS' within the respective class file.

## Refresh Rate
The refresh rate is how often the schedule should be checked in seconds. The default is 1 second.
]]

if not ( StormFox2 ) then
    assert(false, "StormFox2 is not installed. This plugin requires StormFox2 to work.")
end

local rationDoors = {
    ["dispensory_door4"] = true,
    ["dispensory_door8"] = true,
    ["dispensory_door9"] = true,
}

local function ShouldPlaySounds()
    local code = GetGlobalInt("ixCombineCode", 1)
    if ( code <= 2 ) then
        return true
    end

    return false
end

PLUGIN.schedules = {
    {
        on = 1380,
        off = 360,
        name = "Curfew",
        description = "Everyone should be inside by now.",
        onStart = function(info)
            if not ( ShouldPlaySounds() ) then
                return
            end

            netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_curfewon.wav", 500)
            Schema:SendDispatch("Attention residents: Curfew has been initialized and activated! Outdoor movement has been restricted to all citizens. Cooperation with your Civil Protection team is required. Failure to cooperate will result in permanent off-world relocation. Code: Duty, sword, midnight.")
        end,
        onEnd = function(info)
            timer.Simple(10, function()
                if not ( ShouldPlaySounds() ) then
                    return
                end
                
                netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_rationscurfew.wav", 500)
                Schema:SendDispatch("Attention residents: Curfew restrictions have been lifted, you are now permitted with outdoor movement. The Ration Distribution Center is operational for distribution, please proceed efficiently to collect your daily Ration. Code: Inform, cooperate, assemble.")
            end)
        end,
    },
    {
        on = 360,
        off = 480,
        name = "Ration Distribution",
        description = "Rations are being distributed at the town square.",
        onStart = function(info)
            if not ( ShouldPlaySounds() ) then
                return
            end

            netstream.Start(nil, "EmitSound", "minerva/halflife2/music/rations.mp3", 500, nil, 0.5)
            Schema.rationsClaimed = {}

            for k, v in ipairs(ents.FindByClass("ix_ration_dispenser")) do
                v:SetActivated(true)
            end

            for k, v in ents.Iterator() do
                if ( rationDoors[v:GetName()] ) then
                    v:Fire("open")
                end
            end
        end,
        onEnd = function(info)
            if not ( ShouldPlaySounds() ) then
                return
            end

            netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_rationsclosed.wav", 500)
            Schema:SendDispatch("Attention residents, the Ration distribution center has been closed. Those who missed the designated time must vacate the area immediately.")

            for k, v in ipairs(ents.FindByClass("ix_ration_dispenser")) do
                v:SetActivated(false)
                v:EmitError()
            end

            for k, v in ents.Iterator() do
                if ( rationDoors[v:GetName()] ) then
                    v:Fire("close")
                end
            end
        end,
    },
    {
        on = 480,
        off = 780,
        name = "First Free Time",
        description = "You have some free time to do whatever you want.",
        onStart = function(info)
        end,
        onEnd = function(info)
        end,
    },
    {
        on = 780,
        off = 1020,
        name = "Work Cycle",
        description = "Time to get to work.",
        onStart = function(info)
            if not ( ShouldPlaySounds() ) then
                return
            end

            netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_workcycleon.wav", 500)
            Schema:SendDispatch("Attention residents! Your scheduled work session is now in order, you are to proceed to the nearest work shift at your location. Failure to comply will result in criminal trespass. Cooperate, assemble, inform.")
        end,
        onEnd = function(info)
            if not ( ShouldPlaySounds() ) then
                return
            end

            netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_workcycleoff.wav", 500)
            Schema:SendDispatch("Citizen notice: the daily work shift cycle has been completed, you may now resume with your original tasks and duties. Free Time is now in session.")
        end,
    },
    {
        on = 1020,
        off = 1380,
        name = "Secondary Free Time",
        description = "You have some free time to do whatever you want.",
        onStart = function(info)
        end,
        onEnd = function(info)
        end,
    },
}

concommand.Add("ix_schedule_translate", function(ply, command, arguments)
    local time = arguments[1]
    local sf2Time = StormFox2.Time.TimeToString(time)
    
    ply:Notify(sf2Time)
end)

ix.util.Include("sh_hooks.lua")