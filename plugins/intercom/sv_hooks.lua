local PLUGIN = PLUGIN

-- Store player SteamID64 who is currently broadcasting
local currentBroadcaster = nil
local currentBroadcasterEndTime = 0
local activeIntercomEntity = nil -- Store the entity that initiated the broadcast

-- This function is called from the entity's Use function
function PLUGIN:PlayerAttemptUseIntercom(ply, entity)
    local char = ply:GetCharacter()

    -- 0. Basic validity checks
    if not IsValid(ply) or not char then return end
    if not self.allowedFactionIDs then
        ply:Notify("Intercom faction configuration error.")
        ErrorNoHalt("[Project Paragon Intercom] PLUGIN.allowedFactionIDs is not defined!\n")
        return
    end

    -- 1. Faction Check
    if not table.HasValue(self.allowedFactionIDs, char:GetFaction()) then
        ply:Notify("You are not authorized to use this intercom.")
        if (self.soundDenied) then ply:EmitSound(self.soundDenied) end
        return
    end

    -- 2. Global Cooldown Check
    if (CurTime() < self.nextGlobalUseTime) then
        local remaining = math.ceil(self.nextGlobalUseTime - CurTime())
        ply:Notify("The intercom system is on global cooldown for " .. remaining .. "s.")
        if (self.soundDenied) then ply:EmitSound(self.soundDenied) end
        return
    end

    -- 3. Personal Cooldown Check
    local steamID = ply:SteamID64()
    if (self.playerCooldowns[steamID] and CurTime() < self.playerCooldowns[steamID]) then
        local remaining = math.ceil(self.playerCooldowns[steamID] - CurTime())
        ply:Notify("You are on personal intercom cooldown for " .. remaining .. "s.")
        if (self.soundDenied) then ply:EmitSound(self.soundDenied) end
        return
    end

    -- 4. Check if someone else is already broadcasting
    if (currentBroadcaster and IsValid(currentBroadcaster) and CurTime() < currentBroadcasterEndTime) then
        ply:Notify("Someone else is currently broadcasting. Please wait.")
        if (self.soundDenied) then ply:EmitSound(self.soundDenied) end
        return
    end

    -- All checks passed! Start broadcast.
    currentBroadcaster = ply
    currentBroadcasterEndTime = CurTime() + self.broadcastDuration
    activeIntercomEntity = entity

    -- Set cooldowns
    self.playerCooldowns[steamID] = CurTime() + self.personalCooldown
    self.nextGlobalUseTime = CurTime() + self.globalCooldown

    ply:Notify("You are now broadcasting globally for " .. self.broadcastDuration .. " seconds!")
    if (self.soundActivate) then ply:EmitSound(self.soundActivate) end

    -- Optional: Global sound indication
    if (self.soundBroadcastStart and self.soundBroadcastStart ~= "") then
        for _, v_ply in ipairs(player.GetAll()) do
            v_ply:EmitSound(self.soundBroadcastStart)
        end
    end

    -- Update entity state if the functions exist
    if (IsValid(activeIntercomEntity) and activeIntercomEntity.StartBroadcastVisuals) then
        activeIntercomEntity:StartBroadcastVisuals()
    end

    -- Timer to stop the broadcast
    timer.Create("IntercomBroadcast_" .. steamID, self.broadcastDuration, 1, function()
        if (IsValid(ply) and currentBroadcaster == ply) then -- Ensure it's still the same player
            --ply:Notify("Global broadcast finished.")
        end

        if (currentBroadcaster == ply) then -- Clear broadcaster regardless of ply validity if they were the one
            currentBroadcaster = nil
            currentBroadcasterEndTime = 0

            if (IsValid(activeIntercomEntity) and activeIntercomEntity.StopBroadcastVisuals) then
                activeIntercomEntity:StopBroadcastVisuals()
            end
            activeIntercomEntity = nil

            -- Optional: Global sound indication for end
            if (self.soundBroadcastEnd and self.soundBroadcastEnd ~= "") then
                 for _, v_ply in ipairs(player.GetAll()) do
                    v_ply:EmitSound(self.soundBroadcastEnd)
                end
            end
        end
    end)
end

-- Hook into voice system
hook.Add("PlayerCanHearPlayersVoice", "IntercomGlobalVoice", function(listener, talker)
    if (IsValid(talker) and talker == currentBroadcaster and CurTime() < currentBroadcasterEndTime) then
        return true, false
    end
    return nil
end)

-- Clean up player cooldowns if they leave
hook.Add("PlayerDisconnect", "IntercomClearCooldownOnLeave", function(ply)
    local plugin = ix.plugin.Get("intercom")
    if plugin and plugin.playerCooldowns then
        plugin.playerCooldowns[ply:SteamID64()] = nil
    end

    if (currentBroadcaster == ply) then
        currentBroadcaster = nil
        currentBroadcasterEndTime = 0
        if (IsValid(activeIntercomEntity) and activeIntercomEntity.StopBroadcastVisuals) then
            activeIntercomEntity:StopBroadcastVisuals()
        end
        activeIntercomEntity = nil
        timer.Remove("IntercomBroadcast_" .. ply:SteamID64())
    end
end)

-- Optional: If using Helix's character system
-- hook.Add("ixPlayerCharacterSet", "IntercomClearCooldownOnCharSwitch", function(ply, oldChar, newChar)
--     local plugin = ix.plugin.Get("intercom")
--     if plugin and plugin.playerCooldowns then
--         plugin.playerCooldowns[ply:SteamID64()] = nil
--     end
-- end)

-- This hook runs once the gamemode is fully initialized.
-- It's a safe place to use ix.log or other Helix systems.
hook.Add("Initialize", "IntercomPluginReadyLog", function()
    -- Ensure PLUGIN is accessible here. If sv_hooks.lua is loaded in a way that PLUGIN isn't
    -- directly the current plugin's table, we might need to fetch it.
    -- However, typically within plugin files, PLUGIN refers to the current plugin.
    local currentPlugin = ix.plugin.Get("intercom") -- Get the plugin instance
    if currentPlugin and currentPlugin.allowedFactionIDs then
        ix.log.Info("[Intercom Plugin] Intercom system initialized. Authorized Faction IDs: " .. table.concat(currentPlugin.allowedFactionIDs, ", "))
    elseif currentPlugin then
        ix.log.Warning("[Intercom Plugin] Intercom system initialized, but allowedFactionIDs is not set or empty.")
    else
        ix.log.Error("[Intercom Plugin] Could not get 'intercom' plugin instance for logging.")
    end
end)