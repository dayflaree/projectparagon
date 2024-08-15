/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.tickets = PLUGIN.tickets or {}

function PLUGIN:VerifyTicket(steamID64, title, description)
    local bActiveTicket = self.tickets[steamID64]
    if ( bActiveTicket ) then
        return false, "vanguard_tickets_already_active"
    end

    title = title or ""
    description = description or ""
    
    title = string.lower(title)
    description = string.lower(description)

    local titleLength, descriptionLength = #title, #description
    if ( titleLength < 5 ) then
        return false, "vanguard_tickets_title_too_short"
    elseif ( titleLength > 64 ) then
        return false, "vanguard_tickets_title_too_long"
    end

    if ( descriptionLength < 5 ) then
        return false, "vanguard_tickets_description_too_short"
    end

    local canCreateTicket = hook.Run("PlayerCanCreateTicket", steamID64, title, description)
    if ( canCreateTicket == false ) then
        return false, canCreateTicket or "vanguard_tickets_cannot_create"
    end

    return true
end