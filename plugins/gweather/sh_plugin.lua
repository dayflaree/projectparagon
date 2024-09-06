/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

if ( !gWeatherInstalled ) then
    error("[Helix] gWeather is not installed! Please install it to use this plugin!")
end

local PLUGIN = PLUGIN

PLUGIN.name = "gWeather Support"
PLUGIN.description = "Adds an automated weather system which utilizes the gWeather addon."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.types = {
    {"Cloudy", "gw_t1_cloudy", chance = 10},
    {"Heavy Fog", "gw_t1_heavyfog", chance = 5},
    {"Light Rain & Lightning", {"gw_t1_lightrain", "gw_lightning_storm"}, chance = 5},
    {"Light Rain", "gw_t1_lightrain", chance = 10},
    {"None", "none", chance = 50},
    {"Partly cloudly", "gw_t1_partlycloudy", chance = 20}
}

ix.config.Add("weatherEnabled", true, "Whether or not the weather system is enabled.", nil, {
    category = "gWeather"
})

ix.config.Add("weatherInterval", 300, "The interval in seconds between weather changes.", nil, {
    data = {min = 60, max = 3600},
    category = "gWeather"
})

ix.config.Add("weatherDuration", 300, "The duration in seconds of each weather.", nil, {
    data = {min = 60, max = 3600},
    category = "gWeather"
})

PLUGIN.next = PLUGIN.next or CurTime() + ix.config.Get("weatherInterval", 300)

ix.command.Add("WeatherRandomize", {
    description = "Randomizes the weather.",
    adminOnly = true,
    OnRun = function(self, ply)
        local duration, weather = hook.Run("WeatherStart", hook.Run("WeatherGetRandom"))
        if ( duration and weather ) then
            ply:Notify("The weather has been set to " .. weather[1] .. " for " .. string.NiceTime(duration) .. ".")
        end
    end
})

ix.command.Add("WeatherStart", {
    description = "Starts the weather.",
    adminOnly = true,
    arguments = ix.type.text,
    OnRun = function(self, ply, identifier)
        local weather = {}

        for k, v in ipairs(PLUGIN.types) do
            if ( ix.util.StringMatches(k, identifier) or ix.util.StringMatches(v[1], identifier) or ix.util.StringMatches(v[2], identifier) ) then
                weather = v
                break
            end
        end

        if ( weather[1] ) then
            local duration, weather = hook.Run("WeatherStart", weather)
            if ( duration and weather ) then
                ply:Notify("The weather has been set to " .. weather[1] .. " for " .. string.NiceTime(duration) .. ".")
            end
        else
            ply:Notify("The weather type could not be found.")
        end
    end
})

ix.command.Add("WeatherEnd", {
    description = "Ends the weather.",
    adminOnly = true,
    OnRun = function(self, ply, weather)
        hook.Run("WeatherEnd", {weather})

        ply:Notify("The current weather has been ended.")
    end
})

ix.command.Add("WeatherList", {
    description = "Lists all available weather types.",
    adminOnly = true,
    OnRun = function(self, ply)
        ply:Notify("All available weather types have been printed to your console.")

        for k, v in ipairs(PLUGIN.types) do
            ply:PrintMessage(HUD_PRINTCONSOLE, k .. ". " .. v[1])
        end
    end
})

ix.util.Include("sv_hooks.lua")