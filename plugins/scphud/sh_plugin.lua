local PLUGIN = PLUGIN

PLUGIN.name = "Project Paragon HUD & Overlay"
PLUGIN.author = "Day"
PLUGIN.description = "Displays SCP: Containment Breach visuals and a hand icon over interactive items."
PLUGIN.overlayTextureItem   = "projectparagon/gfx/handsymbol2.png"
PLUGIN.overlayTextureButton = "projectparagon/gfx/handsymbol.png"
PLUGIN.overlayIconSize      = 80
PLUGIN.overlayRadius        = 100

PLUGIN.overlayWhitelistedEntities = {
    ["ix_item"]     = true,
    ["func_button"] = true,
    ["pp_intercom"] = true,
    ["guthscp_snav"] = true,
    ["scp_035_real"] = true,
    ["scp_1025"] = true,
    ["scp294r"] = true
}

PLUGIN.overlayWhitelistedModels = {
    ["models/scp/map/button.mdl"]           = true,
    ["models/scp/map/buttoncode.mdl"]       = true,
    ["models/scp/map/buttonkeycard.mdl"]    = true,
    ["models/scp/map/buttonscanner.mdl"]    = true,
    ["models/scp/map/scplever.mdl"]         = true,
    ["models/scp/map/914/914dial.mdl"]      = true,
    ["models/scp/map/914/914key.mdl"]       = true,
    ["models/scp/items/scp-1499.mdl"]       = true,
    ["models/scp/map/079_fence_door.mdl"]   = true,
    ["models/scp/map/fence_door.mdl"]       = true,
    ["models/scp/map/gateb_fence_door.mdl"] = true,
}

if SERVER then
    util.AddNetworkString("ParagonOverlay_FuncButtons")

    local function BroadcastOverlayFuncButtonPositions(targetPlayer)
        local buttonPositionsList = {}
        for _, buttonEntity in ipairs(ents.FindByClass("func_button")) do
            if IsValid(buttonEntity) then
                local center = buttonEntity:LocalToWorld(buttonEntity:OBBCenter())
                table.insert(buttonPositionsList, center)
            end
        end

        net.Start("ParagonOverlay_FuncButtons")
            net.WriteUInt(#buttonPositionsList, 16)
            for _, position in ipairs(buttonPositionsList) do
                net.WriteVector(position)
            end
        if IsValid(targetPlayer) then
            net.Send(targetPlayer)
        else
            net.Broadcast()
        end
    end

    hook.Add("InitPostEntity", "ParagonOverlay_SendFuncButtons_MapLoad", function()
        BroadcastOverlayFuncButtonPositions()
    end)

    hook.Add("PlayerInitialSpawn", "ParagonOverlay_SendFuncButtons_PlayerSpawn", function(ply)
        BroadcastOverlayFuncButtonPositions(ply)
    end)
end

ix.util.Include("cl_plugin.lua")