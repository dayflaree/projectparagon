/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local order = 0

local function AddProperty(key, name, icon, filter, action, receive)
    properties.Add(key, {
        MenuLabel = name,
        Order = order,
        MenuIcon = icon,
        Filter = filter,
        Action = action,
        Receive = receive
    })

    order = order + 1
end

local function AddProperties()
    AddProperty("vanguard_player_kick", "Kick", "icon16/door_out.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyKick") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Kick Player", "Enter the reason for kicking this player.", "", function(text)
            ix.command.Send("PlyKick", id, text)
        end)
    end)

    AddProperty("vanguard_player_ban", "Ban", "icon16/door_in.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyBan") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Ban Player", "Enter the reason for banning this player.", "", function(text)
            Derma_StringRequest("Ban Player", "Enter the duration for banning this player.", "", function(text2)
                local duration = tonumber(text2)
                if ( !duration or !isnumber(duration) ) then return end

                ix.command.Send("PlyBan", id, text, duration)
            end)
        end)
    end)

    AddProperty("vanguard_player_goto", "Goto", "icon16/world_go.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyGoto") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        ix.command.Send("PlyGoto", id)
    end)

    AddProperty("vanguard_player_bring", "Bring", "icon16/world_add.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyBring") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        ix.command.Send("PlyBring", id)
    end)

    AddProperty("vanguard_player_return", "Return", "icon16/world_delete.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyReturn") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        ix.command.Send("PlyReturn", id)
    end)

    AddProperty("vanguard_player_freeze", "Freeze", "icon16/lock.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( ent:GetNetVar("Vanguard.Frozen") ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyFreeze") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        ix.command.Send("PlyFreeze", id)
    end)

    AddProperty("vanguard_player_unfreeze", "Unfreeze", "icon16/lock_open.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !ent:GetNetVar("Vanguard.Frozen") ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyUnFreeze") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        ix.command.Send("PlyUnfreeze", id)
    end)

    AddProperty("vanguard_player_whitelist_faction", "Whitelist Faction", "icon16/user_add.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Whitelist Faction", "Enter the faction you want to whitelist this player to.", "", function(text)
            ix.command.Send("PlyWhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_whitelist_class", "Whitelist Class", "icon16/user_add.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return tobool(ply.HasClassWhitelist)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Whitelist Class", "Enter the class you want to whitelist this player to.", "", function(text)
            ix.command.Send("PlyClassWhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_whitelist_rank", "Whitelist Rank", "icon16/user_add.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return tobool(ply.HasRankWhitelist)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Whitelist Rank", "Enter the rank you want to whitelist this player to.", "", function(text)
            ix.command.Send("PlyRankWhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_unwhitelist_faction", "Unwhitelist Faction", "icon16/user_delete.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Unwhitelist Faction", "Enter the faction you want to unwhitelist this player from.", "", function(text)
            ix.command.Send("PlyUnwhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_unwhitelist_class", "Unwhitelist Class", "icon16/user_delete.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return tobool(ply.HasClassWhitelist)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Unwhitelist Class", "Enter the class you want to unwhitelist this player from.", "", function(text)
            ix.command.Send("PlyUnClassWhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_unwhitelist_rank", "Unwhitelist Rank", "icon16/user_delete.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Manage Character Whitelist") ) then return false end

        return tobool(ply.HasRankWhitelist)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Unwhitelist Rank", "Enter the rank you want to unwhitelist this player from.", "", function(text)
            ix.command.Send("PlyUnRankWhitelist", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_health", "Set Health", "icon16/heart.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( ply:GetMaxHealth() == 0 ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlySetHealth") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Health", "Enter the health you want to set for this player.", "", function(text)
            local health = tonumber(text)
            if ( !health or !isnumber(health) ) then return end

            ix.command.Send("PlySetHealth", id, health)
        end)
    end)

    AddProperty("vanguard_player_set_armor", "Set Armor", "icon16/shield.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( ent:GetMaxArmor() == 0 ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlySetArmor") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Armor", "Enter the armor you want to set for this player.", "", function(text)
            local armor = tonumber(text)
            if ( !armor or !isnumber(armor) ) then return end

            ix.command.Send("PlySetArmor", id, armor)
        end)
    end)

    AddProperty("vanguard_player_set_faction", "Set Faction", "icon16/user_edit.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - PlyTransfer") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Faction", "Enter the faction you want to set for this character.", "", function(text)
            ix.command.Send("PlyTransfer", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_class", "Set Class", "icon16/user_edit.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetClass") ) then return false end

        return tobool(ix.class)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Class", "Enter the class you want to set for this character.", "", function(text)
            ix.command.Send("CharSetClass", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_rank", "Set Rank", "icon16/user_edit.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetRank") ) then return false end

        return tobool(ix.rank)
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Rank", "Enter the rank you want to set for this character.", "", function(text)
            ix.command.Send("CharSetRank", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_money", "Set Money", "icon16/money.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetMoney") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Money", "Enter the money you want to set for this character.", "", function(text)
            local money = tonumber(text)
            if ( !money or !isnumber(money) ) then return end

            ix.command.Send("CharSetMoney", id, money)
        end)
    end)

    AddProperty("vanguard_player_set_flags", "Set Flags", "icon16/shield.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetFlags") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Flags", "Enter the flags you want to set for this character.", "", function(text)
            ix.command.Send("CharSetFlags", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_model", "Set Model", "icon16/user_edit.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetModel") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Model", "Enter the model you want to set for this character.", "", function(text)
            ix.command.Send("CharSetModel", id, text)
        end)
    end)

    AddProperty("vanguard_player_set_skin", "Set Skin", "icon16/user_edit.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - CharSetSkin") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        local id = ent:IsBot() and ent:Nick() or ent:SteamID()

        Derma_StringRequest("Set Skin", "Enter the skin you want to set for this character.", "", function(text)
            local skin = tonumber(text)
            if ( !skin or !isnumber(skin) ) then return end

            ix.command.Send("CharSetSkin", id, skin)
        end)
    end)

    AddProperty("vanguard_player_view_inventory", "View Inventory", "icon16/basket.png", function(self, ent, ply)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Inventory - View") ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return false end

        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end, function(self, len, ply)
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return end

        local ent = net.ReadEntity()
        if ( !IsValid(ent) or !ent:IsPlayer() ) then return end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Inventory - View") ) then return false end

        if ( !self:Filter(ent, ply) ) then return end

        local character = ent:GetCharacter()
        if ( !character ) then return end

        local inventory = character:GetInventory()
        local name = ent:Name()

        ix.storage.Open(ply, inventory, {
            entity = ent,
            name = name
        })
    end)

    AddProperty("vanguard_model_blacklist", "Blacklist Model", "icon16/cancel.png", function(self, ent, ply)
        if ( !IsValid(ent) ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Blacklist - Add", nil) ) then return false end

        local model = ent:GetModel()
        if ( !model or model == "" ) then return false end

        model = model:utf8lower()

        if ( PLUGIN:IsModelBlacklisted(model) ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) ) then return false end

        local model = ent:GetModel()
        if ( !model or model == "" ) then return false end

        model = model:utf8lower()

        PLUGIN:BlacklistModel(model)

        ix.util.NotifyLocalized("vanguard_properties_model_blacklisted", model)
    end)

    AddProperty("vanguard_model_unblacklist", "Unblacklist Model", "icon16/accept.png", function(self, ent, ply)
        if ( !IsValid(ent) ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end
        if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Blacklist - Remove", nil) ) then return false end

        local model = ent:GetModel()
        if ( !model or model == "" ) then return false end

        model = model:utf8lower()

        if ( !PLUGIN:IsModelBlacklisted(model) ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) ) then return false end

        local model = ent:GetModel()
        if ( !model or model == "" ) then return false end

        model = model:utf8lower()

        PLUGIN:UnblacklistModel(model)

        ix.util.NotifyLocalized("vanguard_properties_model_unblacklisted", model)
    end)

    AddProperty("vanguard_model_copy", "Copy Model", "icon16/page_copy.png", function(self, ent, ply)
        if ( !IsValid(ent) ) then return false end
        if ( !IsValid(ply) or !ply:IsPlayer() ) then return false end

        return true
    end, function(self, ent)
        if ( !IsValid(ent) ) then return false end

        local model = ent:GetModel()
        if ( !model or model == "" ) then return false end

        model = model:utf8lower()

        SetClipboardText(model)

        ix.util.NotifyLocalized("vanguard_properties_model_copied", model)
    end)
end

hook.Add("InitPostEntity", "ixVanguardProperties", function()
    AddProperties()
end)

hook.Add("OnReloaded", "ixVanguardProperties", function()
    AddProperties()
end)