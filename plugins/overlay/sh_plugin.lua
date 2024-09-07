local PLUGIN = PLUGIN

PLUGIN.name = "Overlay"
PLUGIN.description = "Adds an overlay to items and buttons."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.color = ColorAlpha(color_white, 255)
PLUGIN.size = 80
PLUGIN.radius = 70
PLUGIN.whitelisted = {
    ["ix_item"] = true,
    ["func_button"] = true,
    ["ix_ammocrate"] = true,
}

// if buttons don't work, we get their model instead..
PLUGIN.modelWhitelisted = {
    ["models/scp/map/button.mdl"] = true,
    ["models/scp/map/buttoncode.mdl"] = true,
    ["models/scp/map/buttonkeycard.mdl"] = true,
    ["models/scp/map/buttonscanner.mdl"] = true,
    ["models/scp/map/scplever.mdl"] = true,
    ["models/scp/map/008_2.mdl"] = true,
    ["models/scp/map/914/914dial.mdl"] = true,
    ["models/scp/map/914/914key.mdl"] = true,
    ["models/scp/items/scp-1499.mdl"] = true,
    ["models/scp/map/079_fence_door.mdl"] = true,
    ["models/scp/map/fence_door.mdl"] = true,
    ["models/scp/map/gateb_fence_door.mdl"] = true
}

PLUGIN.overlayTextureButton = "90/projectparagon/ui/player/hud/hand_symbol1.png"
PLUGIN.overlayTextureItem = "90/projectparagon/ui/player/hud/hand_symbol2.png"

if ( SERVER ) then return end

local overlayTextureItem = ix.util.GetMaterial(PLUGIN.overlayTextureItem)
local overlayTextureButton = ix.util.GetMaterial(PLUGIN.overlayTextureButton)

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    if ( !IsValid(ply) or !ply:Alive() ) then return end

    // Update overlay textures if necessary
    if ( overlayTextureItem != self.overlayTextureItem ) then
        overlayTextureItem = ix.util.GetMaterial(self.overlayTextureItem)
    end

    if ( overlayTextureButton != self.overlayTextureButton ) then
        overlayTextureButton = ix.util.GetMaterial(self.overlayTextureButton)
    end

    local bAlreadyShown = false
    for k, v in ipairs(ents.FindInSphere(ply:EyePos(), self.radius)) do
        if ( !IsValid(v) ) then continue end
        if ( bAlreadyShown ) then break end

        local overlayTexture = nil

        if ( self.whitelisted[v:GetClass()] ) then
            if ( v:GetClass() == "ix_item" ) then
                overlayTexture = overlayTextureItem
            elseif ( v:GetClass() == "func_button" ) then
                overlayTexture = overlayTextureButton
            end
        elseif ( self.modelWhitelisted[v:GetModel()] ) then
            overlayTexture = overlayTextureButton
        end

        if ( overlayTexture ) then
            local pos = v:GetPos():ToScreen()

            surface.SetDrawColor(self.color)
            surface.SetMaterial(overlayTexture)
            surface.DrawTexturedRect(pos.x - self.size / 2, pos.y - self.size / 2, self.size, self.size)

            if ( !bAlreadyShown ) then
                bAlreadyShown = true
            end
        end
    end
end