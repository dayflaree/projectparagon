/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:InitializedConfig()
    ix.config.Add("antiBunnyhop", true, "Prevents players from bunnyhopping.", nil, {
        category = "vanguard"
    })

    ix.config.Add("antiBunnyhopStrength", 0.5, "The strength of the anti-bunnyhop.", nil, {
        category = "vanguard",
        data = {min = 0, max = 1, decimals = 1}
    })

    ix.config.Add("logsPerPage", 150, "The amount of logs per page.", nil, {
        category = "vanguard",
        data = {min = 10, max = 1000}
    })

    ix.config.Add("chatLogs", true, "Sends a notification to all players when a specific command from vanguard is ran, for example kicking and banning commands.", nil, {
        category = "vanguard"
    })

    ix.config.Add("chatLogsAdminOnly", true, "Only send the notification to admins.", nil, {
        category = "vanguard"
    })

    ix.config.Add("vanguardColor", Color(255, 100, 0), "The main color for Vanguard.", nil, {
        category = "vanguard"
    })

    ix.option.Add("observerLightRange", ix.type.number, 8192, {
        category = "vanguard",
        min = 0,
        max = 8192,
        decimals = 0
    })

    ix.option.Add("observerLightColor", ix.type.color, Color(255, 255, 255), {
        category = "vanguard"
    })

    ix.option.Add("observerLightBrightness", ix.type.number, 1, {
        category = "vanguard",
        min = 0,
        max = 10,
        decimals = 1
    })

    ix.option.Add("observerLightFOV", ix.type.number, 170, {
        category = "vanguard",
        min = 0,
        max = 180,
        decimals = 0
    })
end

PLUGIN:InitializedConfig()