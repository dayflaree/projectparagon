/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

util.AddNetworkString("ixVanguardPhysgunPickup")
util.AddNetworkString("ixVanguardPhysgunDrop")

local PLUGIN = PLUGIN

local default = {
    ["models/cliffs/rocks_xlarge02.mdl"] = true,
    ["models/cliffs/rocks_xlarge03_veg.mdl"] = true,
    ["models/combinefortificationv5/combinecitadellewall.mdl"] = true,
    ["models/cranes/crane_frame.mdl"] = true,
    ["models/fruity/new_combine_monitor2.mdl"] = true,
    ["models/hl2signs/z_novaprospekt/novaprospekt_huge.mdl"] = true,
    ["models/hunter/blocks/cube4x6x05.mdl"] = true,
    ["models/hunter/blocks/cube4x6x2.mdl"] = true,
    ["models/hunter/blocks/cube4x6x2.mdl"] = true,
    ["models/hunter/blocks/cube4x6x2.mdl"] = true,
    ["models/hunter/blocks/cube4x8x05.mdl"] = true,
    ["models/hunter/blocks/cube4x8x05.mdl"] = true,
    ["models/hunter/blocks/cube4x8x05.mdl"] = true,
    ["models/hunter/blocks/cube4x8x1.mdl"] = true,
    ["models/hunter/blocks/cube4x8x1.mdl"] = true,
    ["models/hunter/blocks/cube6x6x05.mdl"] = true,
    ["models/hunter/blocks/cube6x6x05.mdl"] = true,
    ["models/hunter/blocks/cube6x6x1.mdl"] = true,
    ["models/hunter/blocks/cube6x6x2.mdl"] = true,
    ["models/hunter/blocks/cube6x6x6.mdl"] = true,
    ["models/hunter/blocks/cube6x8x05.mdl"] = true,
    ["models/hunter/blocks/cube6x8x1.mdl"] = true,
    ["models/hunter/blocks/cube6x8x2.mdl"] = true,
    ["models/hunter/blocks/cube8x8x025.mdl"] = true,
    ["models/hunter/blocks/cube8x8x05.mdl"] = true,
    ["models/hunter/blocks/cube8x8x1.mdl"] = true,
    ["models/hunter/blocks/cube8x8x1.mdl"] = true,
    ["models/hunter/blocks/cube8x8x2.mdl"] = true,
    ["models/hunter/blocks/cube8x8x4.mdl"] = true,
    ["models/hunter/blocks/cube8x8x8.mdl"] = true,
    ["models/items/item_item_crate.mdl"] = true,
    ["models/luminous_propspack_batimentsetautre/largewoodbarricade.mdl"] = true,
    ["models/props/cs_militia/silo_01.mdl"] = true,
    ["models/props/cs_office/microwave.mdl"] = true,
    ["models/props/de_inferno/scaffolding.mdl"] = true,
    ["models/props/de_nuke/coolingtank.mdl"] = true,
    ["models/props/de_train/biohazardtank.mdl"] = true,
    ["models/props_buildings/building_002a.mdl"] = true,
    ["models/props_buildings/collapsedbuilding01a.mdl"] = true,
    ["models/props_buildings/project_building01.mdl"] = true,
    ["models/props_buildings/project_building02.mdl"] = true,
    ["models/props_buildings/project_building03.mdl"] = true,
    ["models/props_buildings/project_destroyedbuildings01.mdl"] = true,
    ["models/props_buildings/row_church_fullscale.mdl"] = true,
    ["models/props_buildings/row_corner_1_fullscale.mdl"] = true,
    ["models/props_buildings/row_gov_fullscale.mdl"] = true,
    ["models/props_buildings/row_res_1_fullscale.mdl"] = true,
    ["models/props_buildings/row_res_2_ascend_fullscale.mdl"] = true,
    ["models/props_buildings/row_res_2_fullscale.mdl"] = true,
    ["models/props_c17/column02a.mdl"] = true,
    ["models/props_c17/consolebox01a.mdl"] = true,
    ["models/props_c17/metalladder003.mdl"] = true,
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_c17/paper01.mdl"] = true,
    ["models/props_c17/smokestack02_large.mdl"] = true,
    ["models/props_c17/trappropeller_engine.mdl"] = true,
    ["models/props_c17/utilitypole01a.mdl"] = true,
    ["models/props_c17/utilitypole01b.mdl"] = true,
    ["models/props_c17/utilitypole01d.mdl"] = true,
    ["models/props_c17/utilitypole02b.mdl"] = true,
    ["models/props_c17/utilitypole03a.mdl"] = true,
    ["models/props_canal/bridge_pillar02.mdl"] = true,
    ["models/props_canal/canal_bridge01.mdl"] = true,
    ["models/props_canal/canal_bridge02.mdl"] = true,
    ["models/props_canal/canal_bridge03a.mdl"] = true,
    ["models/props_canal/canal_bridge03b.mdl"] = true,
    ["models/props_canal/canal_bridge04.mdl"] = true,
    ["models/props_canal/locks_large.mdl"] = true,
    ["models/props_canal/locks_large_b.mdl"] = true,
    ["models/props_combine/combine_citadel001.mdl"] = true,
    ["models/props_combine/combine_mine01.mdl"] = true,
    ["models/props_combine/combinetrain01.mdl"] = true,
    ["models/props_combine/combinetrain02a.mdl"] = true,
    ["models/props_combine/combinetrain02b.mdl"] = true,
    ["models/props_combine/prison01.mdl"] = true,
    ["models/props_combine/prison01b.mdl"] = true,
    ["models/props_combine/prison01c.mdl"] = true,
    ["models/props_debris/concrete_debris128pile001a.mdl"] = true,
    ["models/props_debris/concrete_debris128pile001b.mdl"] = true,
    ["models/props_docks/dock01_pole01a_256.mdl"] = true,
    ["models/props_docks/dock02_pole02a.mdl"] = true,
    ["models/props_foliage/tree_poplar_01.mdl"] = true,
    ["models/props_industrial/bridge.mdl"] = true,
    ["models/props_industrial/gascanister01.mdl"] = true,
    ["models/props_industrial/gascanister02.mdl"] = true,
    ["models/props_junk/garbage_takeoutcarton001a.mdl"] = true,
    ["models/props_junk/gascan001a.mdl"] = true,
    ["models/props_junk/trashdumpster02.mdl"] = true,
    ["models/props_phx/amraam.mdl"] = true,
    ["models/props_phx/ball.mdl"] = true,
    ["models/props_phx/cannonball.mdl"] = true,
    ["models/props_phx/cannonball_solid.mdl"] = true,
    ["models/props_phx/games/chess/board.mdl"] = true,
    ["models/props_phx/huge/evildisc_corp.mdl"] = true,
    ["models/props_phx/huge/tower.mdl"] = true,
    ["models/props_phx/misc/flakshell_big.mdl"] = true,
    ["models/props_phx/misc/potato_launcher_explosive.mdl"] = true,
    ["models/props_phx/mk-82.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/rocket1.mdl"] = true,
    ["models/props_phx/torpedo.mdl"] = true,
    ["models/props_phx/ww2bomb.mdl"] = true,
    ["models/props_rooftop/large_parliament_dome.mdl"] = true,
    ["models/props_trainstation/column_arch001a.mdl"] = true,
    ["models/props_trainstation/pole_448Connection001a.mdl"] = true,
    ["models/props_wasteland/antlionhill.mdl"] = true,
    ["models/props_wasteland/bridge_internals01.mdl"] = true,
    ["models/props_wasteland/bridge_internals02.mdl"] = true,
    ["models/props_wasteland/bridge_internals03.mdl"] = true,
    ["models/props_wasteland/bridge_low_res.mdl"] = true,
    ["models/props_wasteland/bridge_middle.mdl"] = true,
    ["models/props_wasteland/bridge_railing.mdl"] = true,
    ["models/props_wasteland/bridge_side01-other.mdl"] = true,
    ["models/props_wasteland/bridge_side01.mdl"] = true,
    ["models/props_wasteland/bridge_side02-other.mdl"] = true,
    ["models/props_wasteland/bridge_side02.mdl"] = true,
    ["models/props_wasteland/bridge_side03-other.mdl"] = true,
    ["models/props_wasteland/bridge_side03.mdl"] = true,
    ["models/props_wasteland/cargo_container01.mdl"] = true,
    ["models/props_wasteland/cargo_container01.mdl"] = true,
    ["models/props_wasteland/cargo_container01b.mdl"] = true,
    ["models/props_wasteland/cargo_container01c.mdl"] = true,
    ["models/props_wasteland/coolingtank02.mdl"] = true,
    ["models/props_wasteland/cranemagnet01a.mdl"] = true,
    ["models/props_wasteland/depot.mdl"] = true,
    ["models/props_wasteland/rockcliff01b.mdl"] = true,
    ["models/props_wasteland/rockcliff01c.mdl"] = true,
    ["models/props_wasteland/rockcliff01e.mdl"] = true,
    ["models/props_wasteland/rockcliff01f.mdl"] = true,
    ["models/props_wasteland/rockcliff01g.mdl"] = true,
    ["models/props_wasteland/rockcliff01j.mdl"] = true,
    ["models/props_wasteland/rockcliff01k.mdl"] = true,
    ["models/props_wasteland/rockcliff05a.mdl"] = true,
    ["models/props_wasteland/rockcliff05b.mdl"] = true,
    ["models/props_wasteland/rockcliff05e.mdl"] = true,
    ["models/props_wasteland/rockcliff05f.mdl"] = true,
    ["models/props_wasteland/rockcliff06d.mdl"] = true,
    ["models/props_wasteland/rockcliff06i.mdl"] = true,
    ["models/props_wasteland/rockcliff07b.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster01b.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster02a.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster02b.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster02c.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster03a.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster03b.mdl"] = true,
    ["models/props_wasteland/rockcliff_cluster03c.mdl"] = true,
    ["models/props_wasteland/rockgranite01a.mdl"] = true,
    ["models/props_wasteland/rockgranite01b.mdl"] = true,
    ["models/props_wasteland/rockgranite01c.mdl"] = true,
    ["models/props_wasteland/rockgranite02a.mdl"] = true,
    ["models/props_wasteland/rockgranite02b.mdl"] = true,
    ["models/props_wasteland/rockgranite02c.mdl"] = true,
    ["models/props_wasteland/rockgranite03a.mdl"] = true,
    ["models/props_wasteland/rockgranite03b.mdl"] = true,
    ["models/props_wasteland/rockgranite03c.mdl"] = true,
    ["models/props_wasteland/rockgranite04a.mdl"] = true,
    ["models/props_wasteland/rockgranite04b.mdl"] = true,
    ["models/props_wasteland/rockgranite04c.mdl"] = true,
    ["models/props_wasteland/tugtop001.mdl"] = true,
    ["models/props_wasteland/tugtop002.mdl"] = true,
    ["models/roller.mdl"] = true,
    ["models/weapons/w_grenade.mdl"] = true,
    ["models/willard/smelter.mdl"] = true,
    ["models/willard/work/coalrock.mdl"] = true,
    ["models/willard/work/copperrock.mdl"] = true,
    ["models/willard/work/goldrock.mdl"] = true,
    ["models/willard/work/silverrock.mdl"] = true,
    ["models/xqm/coastertrack/special_full_corkscrew_left_4.mdl"] = true,
    ["models/xqm/helicopterrotorhuge.mdl"] = true,
    ["models/xqm/jetbody2big.mdl"] = true,
    ["models/xqm/jetbody2fuselagebig.mdl"] = true,
    ["models/xqm/jetbody2fuselagehuge.mdl"] = true,
    ["models/xqm/jetbody2fuselagelarge.mdl"] = true,
    ["models/xqm/jetbody2huge.mdl"] = true,
    ["models/xqm/jetbody2large.mdl"] = true,
    ["models/xqm/jetbody2tailpiecebig.mdl"] = true,
    ["models/xqm/jetbody2tailpiecehuge.mdl"] = true,
    ["models/xqm/jetbody2tailpiecelarge.mdl"] = true,
    ["models/xqm/jetbody2wingrootbbig.mdl"] = true,
    ["models/xqm/jetbody2wingrootbhuge.mdl"] = true,
    ["models/xqm/jetbody2wingrootblarge.mdl"] = true,
    ["models/xqm/jetbody3_s3.mdl"] = true,
    ["models/xqm/jetbody3_s4.mdl"] = true,
    ["models/xqm/jetbody3_s5.mdl"] = true,
    ["models/xqm/jetwing2big.mdl"] = true,
    ["models/xqm/jetwing2huge.mdl"] = true,
    ["models/xqm/jetwing2large.mdl"] = true,
    ["models/xqm/jetwing2sizable.mdl"] = true
}

function PLUGIN:GetBlacklistedModels()
    return ix.data.Get("blacklistedModels", default, false ,true)
end

function PLUGIN:ResetBlacklistedModels()
    ix.data.Set("blacklistedModels", default, false, true)

    return default
end

function PLUGIN:SetBlacklistedModels(blacklistedModels)
    if ( !blacklistedModels ) then
        blacklistedModels = default
    end

    ix.data.Set("blacklistedModels", blacklistedModels, false, true)

    return blacklistedModels
end

function PLUGIN:BlacklistModel(model)
    local blacklistedModels = self:GetBlacklistedModels()

    blacklistedModels[model] = true

    self:SetBlacklistedModels(blacklistedModels)

    return blacklistedModels
end

function PLUGIN:UnblacklistModel(model)
    local blacklistedModels = self:GetBlacklistedModels()

    blacklistedModels[model] = nil

    self:SetBlacklistedModels(blacklistedModels)

    return blacklistedModels
end

function PLUGIN:IsModelBlacklisted(model)
    local data = self:GetBlacklistedModels()
    return data[model:lower()]
end

function PLUGIN:SyncBlacklistedModels()
    local blacklistedModels = self:GetBlacklistedModels()

    net.Start("ixVanguardBlacklistedModelsSync")
        net.WriteTable(blacklistedModels)
    net.Broadcast()
end

util.AddNetworkString("ixVanguardBlacklistedModelsSync")
util.AddNetworkString("ixVanguardBlacklistedModelsAdd")
util.AddNetworkString("ixVanguardBlacklistedModelsRemove")

net.Receive("ixVanguardBlacklistedModelsAdd", function(_, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Blacklist - Add", nil) ) then return end

    local model = net.ReadString()
    PLUGIN:BlacklistModel(model)
    PLUGIN:SyncBlacklistedModels()
end)

net.Receive("ixVanguardBlacklistedModelsRemove", function(_, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Blacklist - Remove", nil) ) then return end

    local model = net.ReadString()
    PLUGIN:UnblacklistModel(model)
    PLUGIN:SyncBlacklistedModels()
end)