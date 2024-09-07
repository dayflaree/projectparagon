-- Here is where all serverside functions should go.

local workshop_items = engine.GetAddons()

for i = 1, #workshop_items do
    local addon_id = workshop_items[i].wsid

    resource.AddWorkshop(addon_id)
end

hook.Add("GetLogsWebHook", "DiscordLogs", function()
    return "https://discord.com/api/webhooks/1282099802401800212/bOEnjDDwjWTSg8_2Cn7a_rP2ZlbmiW6P7vIRRpUCWCqBxgFa5CuOcYe2aFLmtHx-OI0w"
end)