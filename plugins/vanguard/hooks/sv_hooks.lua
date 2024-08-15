/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:OnPlayerCreateTicket(ply, title, description)
    for k, v in player.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Tickets - View", nil) ) then continue end

        v:NotifyLocalized("vanguard_tickets_new_ticket", ply:Name(), ply:SteamName(), title)
    end
end

function PLUGIN:OnPlayerCloseTicket(ply, ticket)
    for k, v in player.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Tickets - View", nil) ) then continue end

        v:NotifyLocalized("vanguard_tickets_close_ticket", ply:Name(), ply:SteamName(), ticket.title)
    end
end

function PLUGIN:OnPlayerReplyTicket(ply, ticket, reply)
    for k, v in player.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Tickets - View", nil) ) then continue end
        if ( !table.HasValue(ticket.participants, v:SteamID64()) ) then continue end

        v:NotifyLocalized("vanguard_tickets_reply_ticket", ply:Name(), ply:SteamName(), ticket.title, reply)
    end
end

function PLUGIN:OnPlayerClaimTicket(ply, ticket)
    for k, v in player.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Tickets - Claim", nil) ) then continue end

        v:NotifyLocalized("vanguard_tickets_claim_ticket", ply:Name(), ply:SteamName(), ticket.title)
    end

    local tickets_claimed_total = ply:GetData("Vanguard.Tickets.Claimed.Total", 0)
    ply:SetData("Vanguard.Tickets.Claimed.Total", tickets_claimed_total + 1)

    local date = os.date

    local tickets_claimed_week = ply:GetData("Vanguard.Tickets.Claimed.Week", 0)
    local tickets_claimed_week_last = ply:GetData("Vanguard.Tickets.Claimed.Week.Last", 0)

    if ( date("%W") != tickets_claimed_week_last ) then
        ply:SetData("Vanguard.Tickets.Claimed.Week", 1)
        ply:SetData("Vanguard.Tickets.Claimed.Week.Last", date("%W"))
    else
        ply:SetData("Vanguard.Tickets.Claimed.Week", tickets_claimed_week + 1)
    end

    local tickets_claimed_month = ply:GetData("Vanguard.Tickets.Claimed.Month", 0)
    local tickets_claimed_month_last = ply:GetData("Vanguard.Tickets.Claimed.Month.Last", 0)

    if ( date("%m") != tickets_claimed_month_last ) then
        ply:SetData("Vanguard.Tickets.Claimed.Month", 1)
        ply:SetData("Vanguard.Tickets.Claimed.Month.Last", date("%m"))
    else
        ply:SetData("Vanguard.Tickets.Claimed.Month", tickets_claimed_month + 1)
    end

    local tickets_claimed_year = ply:GetData("Vanguard.Tickets.Claimed.Year", 0)
    local tickets_claimed_year_last = ply:GetData("Vanguard.Tickets.Claimed.Year.Last", 0)

    if ( date("%Y") != tickets_claimed_year_last ) then
        ply:SetData("Vanguard.Tickets.Claimed.Year", 1)
        ply:SetData("Vanguard.Tickets.Claimed.Year.Last", date("%Y"))
    else
        ply:SetData("Vanguard.Tickets.Claimed.Year", tickets_claimed_year + 1)
    end

    ply:SaveData()
end

function PLUGIN:PlayerDisconnected(ply)
    if ( self.tickets[ply:SteamID64()] ) then
        self:CloseTicket(ply)
    end
end

function PLUGIN:OnPlayerObserve(ply, state)
    if ( state ) then
        if ( ply:FlashlightIsOn() ) then
            ply:Flashlight(false)
        end
    end
end

function PLUGIN:PlayerSpawnObject(ply, model, ent)
    if ( self:IsModelBlacklisted(model) ) then
        if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Blacklisted Models", nil) ) then
            if ( !ply.ixVanguardBlacklistNextNotify or ply.ixVanguardBlacklistNextNotify < CurTime() ) then
                ply.ixVanguardBlacklistNextNotify = CurTime() + 1
                ply:NotifyLocalized("vanguard_spawn_blacklisted_model_bypassed", model:lower())
            end
        else
            if ( !ply.ixVanguardBlacklistNextNotify or ply.ixVanguardBlacklistNextNotify < CurTime() ) then
                ply.ixVanguardBlacklistNextNotify = CurTime() + 1
                ply:NotifyLocalized("vanguard_spawn_blacklisted_model")
            end

            return false
        end
    end
end

local classes = {
    ["prop_dynamic"] = true,
    ["prop_dynamic_override"] = true,
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

function PLUGIN:OnPhysgunPickup(ply, ent)
    if ( !IsValid(ent) ) then return end

    if ( ent:IsPlayer() and CAMI.PlayerHasAccess(ply, "Helix - Vanguard Props - Bypass", nil) ) then
        ent:SetMoveType(MOVETYPE_FLY)
        return
    end

    if ( !classes[ent:GetClass()] ) then return end

    local entities = {}
    for k, v in pairs(constraint.GetAllConstrainedEntities(ent)) do
        if ( !IsValid(v) ) then continue end
        if ( !classes[v:GetClass()] ) then continue end

        v:SetNetVar("oldColor", v:GetColor())
        v:SetNetVar("oldCollisionGroup", v:GetCollisionGroup())
        v:SetNetVar("oldRenderMode", v:GetRenderMode())
        v:SetNetVar("oldRenderFX", v:GetRenderFX())

        v:SetColor(ColorAlpha(ix.config.Get("vanguardColor"), 200))
        v:SetCollisionGroup(COLLISION_GROUP_WORLD)
        v:SetRenderMode(RENDERMODE_TRANSCOLOR)
        v:SetRenderFX(kRenderFxHologram)

        table.insert(entities, v)
    end

    net.Start("ixVanguardPhysgunPickup")
        net.WritePlayer(ply)
        net.WriteTable(entities)
    net.Broadcast()
end

local physicsClasses = {
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

function PLUGIN:PlayerSpawnedProp(ply, model, ent)
    if ( !IsValid(ent) or !IsValid(ply) ) then return end

    ent:SetNetVar("Vanguard.Owner", ply)

    if ( !physicsClasses[ent:GetClass()] ) then return end

    ent:AddCallback("PhysicsCollide", function(ent, data)
        if ( !IsValid(ent) ) then return end
        if ( !IsValid(data.HitEntity) ) then return end

        hook.Run("VanguardPhysicsCollide", ent, data.HitEntity)
    end)
end

function PLUGIN:PlayerSpawnedSENT(ply, ent)
    if ( !IsValid(ent) ) then return end

    ent:SetNetVar("Vanguard.Owner", ply)

    if ( !physicsClasses[ent:GetClass()] ) then return end

    ent:AddCallback("PhysicsCollide", function(ent, data)
        if ( !IsValid(ent) ) then return end
        if ( !IsValid(data.HitEntity) ) then return end

        hook.Run("VanguardPhysicsCollide", ent, data.HitEntity)
    end)
end

function PLUGIN:PlayerSpawnedVehicle(ply, ent)
    if ( !IsValid(ent) ) then return end

    ent:SetNetVar("Vanguard.Owner", ply)
end

function PLUGIN:PlayerSpawnedRagdoll(ply, model, ent)
    if ( !IsValid(ent) ) then return end

    ent:SetNetVar("Vanguard.Owner", ply)
end

function PLUGIN:EntityTakeDamage(ply, dmginfo)
    local attacker = dmginfo:GetInflictor() or dmginfo:GetAttacker()
    if ( !IsValid(attacker) ) then return end

    if ( physicsClasses[attacker:GetClass()] ) then
        return true
    end
end

function PLUGIN:PlayerMessageSend(speaker, chatType, text, anonymous, receivers, rawText)
    if ( chatType == "ic" ) then
        ix.log.Add(speaker, "chat", chatType:utf8upper(), text)
    end
end

function PLUGIN:DoPlayerDeath(ply, attacker, damageInfo)
    local reason = "vanguard_death_reason_unknown"
    local playerName = ply:Name()
    local attackerName = "unknown"
    local weaponClass = "unknown"

    if ( IsValid(attacker) ) then
        attackerName = attacker:GetClass()

        if ( attacker == ply ) then
            reason = "vanguard_death_reason_suicide"
        elseif ( attacker:IsPlayer() ) then
            attackerName = attacker:GetName()

            local weapon = attacker:GetActiveWeapon()
            if ( IsValid(weapon) ) then
                weaponClass = weapon:GetClass()
                reason = "vanguard_death_reason_player_with_weapon"
            else
                reason = "vanguard_death_reason_player"
            end
        elseif ( attacker:IsNPC() ) then
            reason = "vanguard_death_reason_npc"
        elseif ( attacker:IsVehicle() ) then
            reason = "vanguard_death_reason_vehicle"
        elseif ( attacker:GetClass() == "worldspawn" ) then
            reason = "vanguard_death_reason_world"
        else
            attackerName = attacker:GetName()
            reason = "vanguard_death_reason_other"
        end
    else
        reason = "vanguard_death_reason_unknown"
    end

    local formattedReason = ""
    if reason == "vanguard_death_reason_player_with_weapon" then
        formattedReason = L(reason, ply, playerName, attackerName, weaponClass)
    elseif reason == "vanguard_death_reason_player" or reason == "vanguard_death_reason_npc" or reason == "vanguard_death_reason_other" then
        formattedReason = L(reason, ply, playerName, attackerName)
    else
        formattedReason = L(reason, ply, playerName)
    end

    for k, v in player.Iterator() do
        if ( !IsValid(v) ) then
            continue
        end

        if not ( ply:GetMoveType() == MOVETYPE_NOCLIP and !v:InVehicle() ) then
            continue
        end

        v:SendChatLog(formattedReason)
    end
end

local function IsAdmin(_, ply)
    return ply:IsAdmin()
end

local function IsSuperAdmin(_, ply)
    return ply:IsSuperAdmin()
end

GAMEMODE.PlayerSpawnNPC = IsSuperAdmin
GAMEMODE.PlayerSpawnSENT = IsAdmin
GAMEMODE.PlayerSpawnVehicle = IsAdmin
GAMEMODE.PlayerGiveSWEP = IsSuperAdmin
GAMEMODE.PlayerSpawnSWEP = IsSuperAdmin
GAMEMODE.PlayerSpawnEffect = IsAdmin

function PLUGIN:PlayerSpawnNPC(ply, class, weapon)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - NPC", nil)
end

function PLUGIN:PlayerSpawnSENT(ply, class)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Entity", nil)
end

function PLUGIN:PlayerSpawnVehicle(ply, model, name, vehicleTable)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Vehicles", nil)
end

function PLUGIN:PlayerGiveSWEP(ply, class, info)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Weapons", nil)
end

function PLUGIN:PlayerSpawnSWEP(ply, class, info)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Weapons", nil)
end

function PLUGIN:PlayerSpawnEffect(ply, model)
    return CAMI.PlayerHasAccess(ply, "Helix - Vanguard Spawn - Effects", nil)
end

function PLUGIN:CanPlayerSpawnContainer(ply, model, entity)
    return false
end

function PLUGIN:SaveData()
    self:SaveUserGroups()
    self:SyncUserGroups()
    self:SyncTools()
    self:SyncBlacklistedModels()

    for k, v in player.Iterator() do
        v:SetData("Vanguard.UserGroup", v:GetUserGroup())
        v:SaveData()

        MsgC(Color(0, 255, 0), "[Helix] [Vanguard] ", Color(255, 255, 255), "Saved user group for ", v:Name(), "\n")
    end

    local persistence = ix.plugin.Get("persistence")
    for k, v in ents.Iterator() do
        if ( !IsValid(v) ) then continue end
        if ( !v:GetNetVar("Vanguard.Owner") ) then continue end

        if ( !IsValid(v:GetNetVar("Vanguard.Owner")) ) then
            v:Remove()
        elseif ( IsValid(v:GetNetVar("Vanguard.Owner")) and v:GetNetVar("Persistent") and persistence ) then
            v:SetNetVar("Vanguard.Owner", nil)
        end
    end
end

function PLUGIN:LoadData()
    self:LoadUserGroups()
end

function PLUGIN:OnReloaded()
    self:SyncUserGroups()
    self:SyncTools()
    self:SyncBlacklistedModels()
end

function PLUGIN:PlayerDataLoaded(ply)
    // we are sending way too much data here, we should only send the data that is needed
    self:SyncUserGroups(nil, ply)
    self:SyncTools()
    self:SyncBlacklistedModels()

    local data = ply:GetData("Vanguard.UserGroup")
    if ( !CAMI.GetUsergroup(data) ) then
        ply:SetData("Vanguard.UserGroup", "user")
        ply:SaveData()
        return
    end

    if ( data ) then
        ply:SetUserGroup(data)
    else
        ply:SetUserGroup("user")
        ply:SetData("Vanguard.UserGroup", "user")
        ply:SaveData()
    end
end

function PLUGIN:CanTool(ply, trace, tool)
    if ( !IsValid(ply) ) then return end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Tools - Bypass", nil) ) then
        return true
    end

    if ( self:IsToolRestricted(tool, ply:GetUserGroup()) ) then
        ply:NotifyLocalized("vanguard_tool_restricted")
        return false
    end

    local ent = trace.Entity
    if ( IsValid(ent) ) then
        if ( ent:GetNetVar("Vanguard.Owner") ~= ply ) then
            ply:NotifyLocalized("vanguard_tool_not_owner")
            return false
        end
    end

    return true
end

function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
    if ( !IsValid(talker) ) then return end

    local talkerChar = talker:GetCharacter()
    if ( !talkerChar ) then return end

    if ( self:PlayerIsGagged(talker) ) then
        return false
    end
end

function PLUGIN:PlayerLoadout(ply)
    if ( !IsValid(ply) ) then return end

    self:SyncTickets(ply)
end

function PLUGIN:OnPhysgunFreeze(weapon, physObj, entity, ply)
    if ( !IsValid(entity) ) then return end
    if ( !IsValid(ply) ) then return end

    if ( CAMI.PlayerHasAccess(ply, "Helix - Vanguard Props - Bypass", nil) ) then
        if ( entity:IsPlayer() ) then
            local id = entity:SteamID()
            if ( entity:IsBot() ) then
                id = entity:GetName()
            end

            if ( entity:GetNetVar("Vanguard.Frozen") ) then
                ix.command.Run(ply, "PlyUnFreeze", {id})
            else
                ix.command.Run(ply, "PlyFreeze", {id})
            end
        end

        return
    end

    if ( entity:GetNetVar("Vanguard.Owner") != ply ) then
        return false
    end
end

hook.Add("CAMI.SignalUserGroupChanged", "Vanguard.CAMI.SignalUserGroupChanged", function(ply, old, new, source)
    if ( !IsValid(ply) ) then return end

    local oldData = CAMI.GetUsergroup(old)
    local newData = CAMI.GetUsergroup(new)

    if ( !oldData or !newData ) then return end

    ply:SetData("Vanguard.UserGroup", new)
    ply:SaveData()
end)

local nextThink = 0
function PLUGIN:Think()
    if ( CurTime() < nextThink ) then return end
    nextThink = CurTime() + 1

    for k, v in player.Iterator() do
        local group = v:GetUserGroup()
        local data = CAMI.GetUsergroup(group)
        if ( !data ) then continue end

        local color = data.Color
        local realColor = Color(color.r, color.g, color.b, color.a or 255)

        v:SetWeaponColor(realColor:ToVector())
    end
end