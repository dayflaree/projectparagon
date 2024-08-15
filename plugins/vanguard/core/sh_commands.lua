/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:InitializedChatClasses()
    ix.command.Add("PlyTeleportToArea", {
        description = "@vanguard_cmd_teleport_area",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.string
        },
        OnRun = function(this, ply, target, area)
            self:PlayerTeleportToArea(ply, target, area)
        end
    })

    ix.command.Add("PlyTeleportTo", {
        description = "@vanguard_cmd_teleport",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.player
        },
        OnRun = function(this, ply, target1, target2)
            self:PlayerTeleportToTarget(ply, target1, target2)
        end
    })

    ix.command.Add("PlyBring", {
        description = "@vanguard_cmd_teleport_bring",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        OnRun = function(this, ply, target)
            self:PlayerBring(ply, target)
        end
    })

    ix.command.Add("PlyReturn", {
        description = "@vanguard_cmd_teleport_return",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        OnRun = function(this, ply, target)
            self:PlayerReturn(ply, target)
        end
    })

    ix.command.Add("PlyGoto", {
        description = "@vanguard_cmd_teleport_goto",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        OnRun = function(this, ply, target)
            self:PlayerGoto(ply, target)
        end
    })

    ix.command.Add("ToggleIncognito", {
        description = "@vanguard_cmd_toggle_incognito",
        adminOnly = true,
        OnRun = function(this, ply)
            local incognito = !ply:GetNetVar("bIncognito", false)
            ply:SetNetVar("bIncognito", incognito)

            local text = "turned on"
            if ( !incognito ) then
                text = "turned off"
            end

            hook.Run("PlayerToggleIncognito", ply, ply:GetNetVar("bIncognito", false))

            if ( !ply:IsSuperAdmin() ) then
                PLUGIN:SendChatLog(ply, color_white, " has " .. text .. " incognito mode.")
            end

            ply:NotifyLocalized("vanguard_incognito_toggle", text)
        end
    })

    ix.command.Add("PlyGiveAmmo", {
        description = "@vanguard_cmd_giveammo",
        superAdminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.number
        },
        OnRun = function(this, ply, target, amount)
            if not ( target ) then
                target = ply
            end

            local wep = target:GetActiveWeapon()
            if not ( IsValid(wep) ) then
                return target:NotifyLocalized("vanguard_no_weapon")
            end

            target:GiveAmmo(amount, wep:GetPrimaryAmmoType())
        end
    })

    ix.command.Add("PlyRespawn", {
        description = "@vanguard_cmd_respawn",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        OnRun = function(this, ply, target)
            target:Spawn()

            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_respawn_callback", target:GetName())
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_respawn_callback_self")
            else
                target:NotifyLocalized("vanguard_cmd_respawn_callback_target", ply:GetName())
            end
        end
    })

    ix.command.Add("PlyKick", {
        description = "@vanguard_cmd_kick",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.text
        },
        OnRun = function(this, ply, target, reason)
            self:PlayerKick(ply, target, reason)
        end
    })

    ix.command.Add("PlyBan", {
        description = "@vanguard_cmd_ban",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.string,
            ix.type.number
        },
        OnRun = function(this, ply, target, reason, duration)
            self:PlayerBan(ply, target, reason, duration)
        end
    })

    ix.command.Add("PlySetHealth", {
        description = "@vanguard_cmd_sethealth",
        adminOnly = true,
        arguments = {
            bit.bor(ix.type.player, ix.type.optional),
            bit.bor(ix.type.number, ix.type.optional)
        },
        OnRun = function(this, ply, target, health)
            if ( target == nil ) then
                target = ply
            end

            if ( health == nil ) then
                health = target:GetMaxHealth()
            end

            target:SetHealth(health)

            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_sethealth_callback", target:GetName(), health)
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_sethealth_callback_self", health)
            else
                target:NotifyLocalized("vanguard_cmd_sethealth_callback_target", health, ply:GetName())
            end
        end
    })

    ix.command.Add("PlySetArmor", {
        description = "@vanguard_cmd_setarmor",
        adminOnly = true,
        arguments = {
            bit.bor(ix.type.player, ix.type.optional),
            bit.bor(ix.type.number, ix.type.optional)
        },
        OnRun = function(this, ply, target, armor)
            if ( target == nil ) then
                target = ply
            end

            if ( armor == nil ) then
                armor = target:GetMaxArmor()
            end

            target:SetArmor(armor)

            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_setarmor_callback", target:GetName(), armor)
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_setarmor_callback_self", armor)
            else
                target:NotifyLocalized("vanguard_cmd_setarmor_callback_target", armor, ply:GetName())
            end
        end
    })

    ix.command.Add("PlySetSubMaterial", {
        description = "@vanguard_cmd_setsubmaterial",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.number,
            bit.bor(ix.type.string, ix.type.optional)
        },
        OnRun = function(this, ply, target, index, material)
            material = material or ""
            target:SetSubMaterial(index, material)

            if ( material == "" ) then
                material = L("vanguard_cmd_setsubmaterial_callback_default", target)
            end

            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_setsubmaterial_callback", target:GetName(), index, material)
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_setsubmaterial_callback_self", index, material)
            else
                target:NotifyLocalized("vanguard_cmd_setsubmaterial_callback_target", index, material, ply:GetName())
            end
        end
    })

    ix.command.Add("PlySetUserGroup", {
        description = "@vanguard_cmd_setusergroup",
        superAdminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.string
        },
        OnRun = function(this, ply, target, usergroup)
            local can, err = self:PlayerSetUserGroup(ply, target, usergroup)
            if ( err ) then
                ply:NotifyLocalized(err)
            end
        end
    })

    // comment: Debug commands for developers
    ix.command.Add("SaveData", {
        description = "@vanguard_cmd_savedata",
        adminOnly = true,
        OnRun = function(this, ply)
            hook.Run("SaveData")
        end
    })

    ix.command.Add("CleanUpMap", {
        description = "@vanguard_cmd_cleanup_map",
        superAdminOnly = true,
        OnRun = function(this, ply)
            game.CleanUpMap()

            PLUGIN:SendChatLog(ply, color_white, " has cleaned up the map.")
        end
    })

    ix.command.Add("CleanUpDecals", {
        description = "@vanguard_cmd_cleanup_decals",
        adminOnly = true,
        OnRun = function(this, ply)
            for _, v in player.Iterator() do
                v:ConCommand("r_cleardecals")
            end

            PLUGIN:SendChatLog(ply, color_white, " has removed all decals within the map.")
        end
    })

    ix.command.Add("CleanUpCorpses", {
        description = "@vanguard_cmd_cleanup_corpses",
        adminOnly = true,
        OnRun = function(this, ply)
            for _, v in ents.Iterator() do
                if ( v:GetClass() != "prop_ragdoll" ) then
                    continue
                end

                if not ( v:GetNetVar("player") ) then
                    continue
                end

                v:Remove()
            end

            PLUGIN:SendChatLog(ply, color_white, " has removed all corpses on the ground within the map.")
        end
    })

    ix.command.Add("CleanUpItems", {
        description = "@vanguard_cmd_cleanup_items",
        adminOnly = true,
        OnRun = function(this, ply)
            for _, v in ents.Iterator() do
                if ( v:GetClass() != "ix_item" ) then
                    continue
                end

                v:Remove()
            end

            PLUGIN:SendChatLog(ply, color_white, " has removed all items on the ground within the map.")
        end
    })

    ix.command.Add("Screengrab", {
        description = "@vanguard_cmd_screengrab",
        adminOnly = true,
        OnRun = function(this, ply)
            ply:ConCommand("screengrab")
        end
    })

    ix.command.Add("VanguardMenu", {
        description = "@vanguard_cmd_menu",
        adminOnly = true,
        OnRun = function(this, ply)
            ply:ConCommand("ix_vanguard_menu")
        end
    })

    ix.command.Add("PlyGag", {
        description = "@vanguard_cmd_gag",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.number
        },
        syntax = "<string target> <number minutes>",
        OnRun = function(this, ply, target, minutes)
            if ( self:PlayerIsGagged(target) ) then
                ply:Notify("This player is already gagged.")
                return
            end

            self:PlayerGag(target, minutes)

            local realTime = minutes * 60
            ply:Notify("You have gagged" .. target:GetName() .. " for " .. string.NiceTime(realTime) .. ".")
        end
    })

    ix.command.Add("PlyUnGag", {
        description = "@vanguard_cmd_ungag",
        adminOnly = true,
        arguments = {
            ix.type.player,
        },
        syntax = "<string target> <number minutes>",
        OnRun = function(this, ply, target, minutes)
            if ( !self:PlayerIsGagged(target) ) then
                ply:Notify("This player is not gagged.")
                return
            end

            self:PlayerUnGag(target)
            ply:Notify("You have ungagged " .. target:GetName() .. ".")
        end
    })

    ix.command.Add("PlyOOCTimeout", {
        description = "@vanguard_cmd_ooc_timeout",
        adminOnly = true,
        arguments = {
            ix.type.player,
            ix.type.number
        },
        syntax = "<string target> <number minutes>",
        OnRun = function(this, ply, target, minutes)
            if ( self:PlayerHasOOCTimeout(target) ) then
                ply:Notify("This player already has an OOC timeout.")
                return
            end

            self:PlayerOOCTimeout(target, minutes)

            local realTime = minutes * 60
            ply:NotifyLocalized("vanguard_cmd_ooc_timeout_callback", target:GetName(), string.NiceTime(realTime))
        end
    })

    ix.command.Add("PlyUnOOCTimeout", {
        description = "@vanguard_cmd_ooc_untimeout",
        adminOnly = true,
        arguments = {
            ix.type.player,
        },
        syntax = "<string target>",
        OnRun = function(this, ply, target)
            if ( !self:PlayerHasOOCTimeout(target) ) then
                ply:Notify("This player does not have an OOC timeout.")
                return
            end

            self:PlayerUnOOCTimeout(target)
            ply:NotifyLocalized("vanguard_cmd_ooc_untimeout_callback", target:GetName())
        end
    })

    ix.command.Add("PlyFreeze", {
        description = "@vanguard_cmd_freeze",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        syntax = "<string target>",
        OnRun = function(this, ply, target)
            if ( target:GetNetVar("Vanguard.Frozen") ) then
                ply:NotifyLocalized("vanguard_cmd_freeze_callback_frozen", target:GetName())
                return
            end

            target:SetNetVar("Vanguard.Frozen", true)
            target:Lock()
            
            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_freeze_callback", target:GetName())
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_freeze_callback_self")
            else
                target:NotifyLocalized("vanguard_cmd_freeze_callback_target", ply:GetName())
            end

            PLUGIN:SendChatLog(ply, color_white, " has frozen " .. target:GetName() .. ".")
        end
    })

    ix.command.Add("PlyUnFreeze", {
        description = "@vanguard_cmd_unfreeze",
        adminOnly = true,
        arguments = {
            ix.type.player
        },
        syntax = "<string target>",
        OnRun = function(this, ply, target)
            if ( !target:GetNetVar("Vanguard.Frozen") ) then
                ply:NotifyLocalized("vanguard_cmd_unfreeze_callback_unfrozen", target:GetName())
                return
            end

            target:SetNetVar("Vanguard.Frozen", false)
            target:UnLock()

            if ( target != ply ) then
                ply:NotifyLocalized("vanguard_cmd_unfreeze_callback", target:GetName())
            elseif ( target == ply ) then
                target:NotifyLocalized("vanguard_cmd_unfreeze_callback_self")
            else
                target:NotifyLocalized("vanguard_cmd_unfreeze_callback_target", ply:GetName())
            end

            PLUGIN:SendChatLog(ply, color_white, " has unfrozen " .. target:GetName() .. ".")
        end
    })

    ix.chat.Register("vanguard_chat_staff", {
        indicator = "chatPerforming",
        prefix = {"/sc", "/ac", "/StaffChat", "/AdminChat"},
        description = "@vanguard_chat_desc_staff",
        font = "VanguardChatFont",
        CanSay = function(this, speaker, text)
            return CAMI.PlayerHasAccess(speaker, "Helix - Vanguard Chat - Staff Chat", nil)
        end,
        CanHear = function(this, speaker, listener)
            return CAMI.PlayerHasAccess(listener, "Helix - Vanguard Chat - Staff Chat", nil)
        end,
        OnChatAdd = function(this, speaker, text)
            if ( IsValid(speaker) ) then
                local color = team.GetColor(speaker:Team())
                local configColor = ix.config.Get("color")

                chat.AddText(ix.config.Get("vanguardColor"), "[VANGUARD] ", configColor, "[STAFF] ", color_white, speaker:SteamName(), color, " (" .. speaker:GetName() .. ")", color_white, ": ", text)
            end
        end
    })

    ix.chat.Register("vanguard_chat_gamemaster", {
        indicator = "chatPerforming",
        prefix = {"/gc", "/gmc", "/GameMasterChat", "/GameMaster"},
        description = "@vanguard_chat_desc_gamemaster",
        font = "VanguardChatFont",
        CanSay = function(this, speaker, text)
            return CAMI.PlayerHasAccess(speaker, "Helix - Vanguard Chat - Game Master Chat", nil)
        end,
        CanHear = function(this, speaker, listener)
            return CAMI.PlayerHasAccess(listener, "Helix - Vanguard Chat - Game Master Chat", nil)
        end,
        OnChatAdd = function(this, speaker, text)
            if ( IsValid(speaker) ) then
                local color = team.GetColor(speaker:Team())
                local configColor = ix.config.Get("color")

                chat.AddText(ix.config.Get("vanguardColor"), "[VANGUARD] ", configColor, "[GAME MASTER] ", color_white, speaker:SteamName(), color, " (" .. speaker:GetName() .. ")", color_white, ": ", text)
            end
        end
    })

    ix.chat.Register("vanguard_chat_higherups", {
        indicator = "chatPerforming",
        prefix = {"/hc", "/hu", "/HigherUpChat", "/HigherUp"},
        description = "@vanguard_chat_desc_higherups",
        font = "VanguardChatFont",
        CanSay = function(this, speaker, text)
            return CAMI.PlayerHasAccess(speaker, "Helix - Vanguard Chat - Higher Up Chat", nil)
        end,
        CanHear = function(this, speaker, listener)
            return CAMI.PlayerHasAccess(listener, "Helix - Vanguard Chat - Higher Up Chat", nil)
        end,
        OnChatAdd = function(this, speaker, text)
            if ( IsValid(speaker) ) then
                local color = team.GetColor(speaker:Team())
                local configColor = ix.config.Get("color")

                chat.AddText(ix.config.Get("vanguardColor"), "[VANGUARD] ", configColor, "[HIGHER UP] ", color_white, speaker:SteamName(), color, " (" .. speaker:GetName() .. ")", color_white, ": ", text)
            end
        end
    })

    ix.command.Add("DoorForceSell", {
        description = "@vanguard_cmd_doorforcesell",
        adminOnly = true,
        OnRun = function(this, ply, target)
            local entity = ply:GetEyeTrace().Entity

            if ( IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled") and IsValid(entity:GetDTEntity(0)) ) then
                entity = IsValid(entity.ixParent) and entity.ixParent or entity
                local client = entity:GetDTEntity(0)

                local price = math.Round(entity:GetNetVar("price", ix.config.Get("doorCost")) * ix.config.Get("doorSellRatio"))
                local character = client:GetCharacter()

                entity:RemoveDoorAccessData()

                local doors = character:GetVar("doors") or {}

                for k, v in ipairs(doors) do
                    if (v == entity) then
                        table.remove(doors, k)
                    end
                end

                character:SetVar("doors", doors, true)

                character:GiveMoney(price)
                hook.Run("OnPlayerPurchaseDoor", ply, entity, false, PLUGIN.CallOnDoorChildren)

                ix.log.Add(client, "selldoor")
                return "@dSold", ix.currency.Get(price)
            else
                return "@dNotValid"
            end
        end
    })

    ix.command.list["TeleportToArea"] = ix.command.list["PlyTeleportToArea"]
    ix.command.list["TeleportTo"] = ix.command.list["PlyTeleportTo"]
    ix.command.list["Bring"] = ix.command.list["PlyBring"]
    ix.command.list["Goto"] = ix.command.list["PlyGoto"]
    ix.command.list["GiveAmmo"] = ix.command.list["PlyGiveAmmo"]
    ix.command.list["Respawn"] = ix.command.list["PlyRespawn"]
    ix.command.list["Kick"] = ix.command.list["PlyKick"]
    ix.command.list["Ban"] = ix.command.list["PlyBan"]
    ix.command.list["SetHealth"] = ix.command.list["PlySetHealth"]
    ix.command.list["SetArmor"] = ix.command.list["PlySetArmor"]
    ix.command.list["SetSubMaterial"] = ix.command.list["PlySetSubMaterial"]
end

PLUGIN:InitializedChatClasses()