-- gamemodes/your_schema/plugins/overlay/sh_plugin.lua
local PLUGIN = PLUGIN

PLUGIN.name        = "Overlay"
PLUGIN.author      = "Day"
PLUGIN.description = "Shows a hand icon over ix_item and func_button brushes (and whitelisted button models)."

-- Icon textures (paths under materials/)
PLUGIN.overlayTextureItem   = "projectparagon/gfx/handsymbol2.png"
PLUGIN.overlayTextureButton = "projectparagon/gfx/handsymbol.png"

-- Icon size in px and detection radius in world units
PLUGIN.size   = 80
PLUGIN.radius = 100  -- ← change this to whatever range you like

-- Only highlight these classes
PLUGIN.whitelisted = {
    ["ix_item"]     = true,
    ["func_button"] = true,
}

-- …and these specific button models (lowercased)
PLUGIN.modelWhitelisted = {
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
    util.AddNetworkString("Overlay_FuncButtons")

    local function BroadcastButtons(target)
        local list = {}
        for _, btn in ipairs(ents.FindByClass("func_button")) do
            list[#list+1] = btn:LocalToWorld(btn:OBBCenter())
        end

        net.Start("Overlay_FuncButtons")
            net.WriteUInt(#list, 16)
            for _, pos in ipairs(list) do
                net.WriteVector(pos)
            end
        if target then
            net.Send(target)
        else
            net.Broadcast()
        end
    end

    hook.Add("InitPostEntity",     "Overlay_SendButtons",       function() BroadcastButtons() end)
    hook.Add("PlayerInitialSpawn", "Overlay_SendButtons_Player",function(p) BroadcastButtons(p) end)

    return
end

-- ────────────────────────────────────────────────────────────────────────────
-- CLIENT SIDE
-- ────────────────────────────────────────────────────────────────────────────

local buttonPositions = {}
net.Receive("Overlay_FuncButtons", function()
    local n = net.ReadUInt(16)
    buttonPositions = {}
    for i = 1, n do
        buttonPositions[#buttonPositions+1] = net.ReadVector()
    end
end)

local matItem   = ix.util.GetMaterial(PLUGIN.overlayTextureItem)
local matButton = ix.util.GetMaterial(PLUGIN.overlayTextureButton)

hook.Add("HUDPaint", "Overlay_Draw", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then
        return
    end

    local eyePos = ply:EyePos()
    local tr     = ply:GetEyeTrace()
    local center = tr.HitPos

    -- Recompute the squared radius each frame
    local radius   = PLUGIN.radius or 0
    local radiusSq = radius * radius

    -- We'll track the best‐candidate distance and draw info
    local bestDist2    = radiusSq
    local bestDrawPos  = nil
    local bestMaterial = nil

    -- 1) Check brush‐button positions (from server)
    for _, pos in ipairs(buttonPositions) do
        local d2 = eyePos:DistToSqr(pos)
        if d2 < bestDist2 then
            bestDist2    = d2
            bestDrawPos  = pos
            bestMaterial = matButton
        end
    end

    -- 2) Check ix_items and any whitelisted‐model props around the eye
    for _, ent in ipairs(ents.FindInSphere(eyePos, radius)) do
        if not IsValid(ent) then continue end

        local cls = ent:GetClass()
        local mdl = (ent:GetModel() or ""):lower()
        local isItem  = cls == "ix_item"
        local isModel = PLUGIN.modelWhitelisted[mdl]

        if isItem or isModel then
            -- Compute the true center of that model
            local mn, mx    = ent:GetRenderBounds()
            local worldMin  = ent:LocalToWorld(mn)
            local worldMax  = ent:LocalToWorld(mx)
            local centerEnt = (worldMin + worldMax) * 0.5

            local d2 = eyePos:DistToSqr(centerEnt)
            if d2 < bestDist2 then
                bestDist2    = d2
                bestDrawPos  = centerEnt
                bestMaterial = isItem and matItem or matButton
            end
        end
    end

    -- 3) Bail out if nothing was close enough
    if not bestDrawPos then
        return
    end

    -- 4) Project and draw the icon
    local scr = bestDrawPos:ToScreen()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(bestMaterial)
    surface.DrawTexturedRect(
        scr.x - PLUGIN.size / 2,
        scr.y - PLUGIN.size / 2,
        PLUGIN.size, PLUGIN.size
    )
end)
