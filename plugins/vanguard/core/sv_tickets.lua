/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.tickets = PLUGIN.tickets or {}

util.AddNetworkString("ixVanguardSyncTickets")
function PLUGIN:SyncTickets(target)
    for _, v in player.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Tickets - View", nil) and v != target ) then continue end

        net.Start("ixVanguardSyncTickets")
            net.WriteTable(self.tickets)
        net.Send(v)
    end
end

function PLUGIN:VerifyTicket(steamID64, title, description)
    if ( !steamID64 ) then
        return false, "vanguard_tickets_no_steamid"
    end

    if ( !title or title == "" ) then
        return false, "vanguard_tickets_no_title"
    end

    if ( !description or description == "" ) then
        return false, "vanguard_tickets_no_description"
    end

    if ( self.tickets[steamID64] ) then
        return false, "vanguard_tickets_already_active"
    end

    return true
end

function PLUGIN:CreateTicket(ply, title, description)
    local steamID64 = ply:SteamID64()

    local bSuccess, message = self:VerifyTicket(steamID64, title, description)
    if ( !bSuccess ) then
        return ply:NotifyLocalized(message)
    end

    self.tickets[steamID64] = {
        title = title,
        description = description,
        replies = {},
        created = os.time(),
        updated = os.time(),
        claimed = false,
        claimedBy = nil,
        participants = {
            ply:SteamID64()
        }
    }

    self:SyncTickets(ply)

    ply:NotifyLocalized("vanguard_tickets_created")

    hook.Run("OnPlayerCreateTicket", ply, title, description)
end

function PLUGIN:CloseTicket(ply)
    local steamID64 = ply:SteamID64()
    local bActiveTicket = self.tickets[steamID64]
    if ( !bActiveTicket ) then
        return ply:NotifyLocalized("vanguard_tickets_no_active")
    end

    self.tickets[steamID64] = nil

    self:SyncTickets(ply)

    ply:NotifyLocalized("vanguard_tickets_closed")

    hook.Run("OnPlayerCloseTicket", ply, bActiveTicket)
end

function PLUGIN:ReplyTicket(ply, steamID64, reply)
    local bActiveTicket = self.tickets[steamID64]
    if ( !bActiveTicket ) then
        return ply:NotifyLocalized("vanguard_tickets_no_active")
    end

    if ( !reply or reply == "" ) then return end

    if not ( ply:SteamID64() == bActiveTicket.participants[1] or CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tickets - Reply", nil) ) then
        return ply:NotifyLocalized("vanguard_tickets_no_permission_reply")
    end

    table.insert(bActiveTicket.replies, {
        steamID64 = ply:SteamID64(),
        reply = reply,
        created = os.time()
    })

    if ( !table.HasValue(bActiveTicket.participants, ply:SteamID64()) ) then
        table.insert(bActiveTicket.participants, ply:SteamID64())
    end

    bActiveTicket.updated = os.time()

    self:SyncTickets(ply)

    ply:NotifyLocalized("vanguard_tickets_replied")

    hook.Run("OnPlayerReplyTicket", ply, bActiveTicket, reply)
end

function PLUGIN:ClaimTicket(ply, steamID64)
    local bActiveTicket = self.tickets[steamID64]
    if ( !bActiveTicket ) then
        return ply:NotifyLocalized("vanguard_tickets_no_active")
    end

    if ( bActiveTicket.claimed ) then
        return ply:NotifyLocalized("vanguard_tickets_already_claimed")
    end

    bActiveTicket.claimed = true
    bActiveTicket.claimedBy = ply:SteamID64()

    if ( !table.HasValue(bActiveTicket.participants, ply:SteamID64()) ) then
        table.insert(bActiveTicket.participants, ply:SteamID64())
    end

    self:SyncTickets(ply)

    ply:NotifyLocalized("vanguard_tickets_claimed")

    local target = player.GetBySteamID64(steamID64)
    if ( IsValid(target) ) then
        target:NotifyLocalized("vanguard_tickets_claimed_target", ply:Name(), ply:SteamName())
    end

    hook.Run("OnPlayerClaimTicket", ply, bActiveTicket)
end

util.AddNetworkString("ixVanguardCreateTicket")
net.Receive("ixVanguardCreateTicket", function(len, ply)
    if ( !IsValid(ply) ) then return end

    local title = net.ReadString()
    local description = net.ReadString()
    local steamID64 = ply:SteamID64()

    title = ix.chat.Format(title)
    description = ix.chat.Format(description)

    PLUGIN:CreateTicket(ply, title, description)
end)

util.AddNetworkString("ixVanguardCloseTicket")
net.Receive("ixVanguardCloseTicket", function(len, ply)
    if ( !IsValid(ply) ) then return end

    PLUGIN:CloseTicket(ply)
end)

util.AddNetworkString("ixVanguardReplyTicket")
net.Receive("ixVanguardReplyTicket", function(len, ply)
    if ( !IsValid(ply) ) then return end

    local steamID64 = net.ReadString()
    local reply = net.ReadString()

    PLUGIN:ReplyTicket(ply, steamID64, reply)
end)

util.AddNetworkString("ixVanguardCloseTicketAdmin")
net.Receive("ixVanguardCloseTicketAdmin", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tickets - Close", nil) ) then return end

    local steamID64 = net.ReadString()
    local target = player.GetBySteamID64(steamID64)
    if ( !IsValid(target) ) then return end

    PLUGIN:CloseTicket(target)

    target:NotifyLocalized("vanguard_tickets_closed_admin", ply:Name())
end)

util.AddNetworkString("ixVanguardClaimTicket")
net.Receive("ixVanguardClaimTicket", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tickets - Claim", nil) ) then return end

    local steamID64 = net.ReadString()

    PLUGIN:ClaimTicket(ply, steamID64)
end)