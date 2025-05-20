-- Here is where all clientside functions should go.
local menu = ix.util.GetMaterial("projectparagon/gfx/menu/menublack.png")
local menuwhite = ix.util.GetMaterial("projectparagon/gfx/menu/menuwhite.png")

function Schema:DrawFullOutlinedPanel(this, width, height)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(menu)
    surface.DrawTexturedRect(0, 0, width, height)
    
    surface.SetDrawColor(color_white)

    surface.DrawOutlinedRect(0, 0, width, height)
end

function Schema:DrawOutlinedPanel(this, width, height)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(menu)
    surface.DrawTexturedRect(0, 0, width, width)
    surface.DrawTexturedRect(width, 0, width, width)
    
    surface.SetDrawColor(color_white)

    surface.DrawOutlinedRect(0, 0, width, height)
end

concommand.Add("ix_debug_pos", function(ply)
    local pos = ply:GetPos()

    local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
    chat.AddText(output)

    SetClipboardText(output)
end)

concommand.Add("ix_debug_eyepos", function(ply)
    local pos = ply:EyePos()

    local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
    chat.AddText(output)

    SetClipboardText(output)
end)

concommand.Add("ix_debug_ang", function(ply)
    local pos = ply:EyeAngles()

    local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
    chat.AddText(output)

    SetClipboardText(output)
end)

concommand.Add("ix_debug_getbones", function(ply)
    local ent = ply:GetEyeTrace().Entity
    if not ( ent and IsValid(ent) ) then
        print("Invalid entity")
        return
    end
    
    for i = 0, ent:GetBoneCount() - 1 do
        local bonepos = ent:GetBonePosition(i)
        print("Bone "..i.."\nName: "..ent:GetBoneName(i).."\nVector("..bonepos.x..", "..bonepos.y..", "..bonepos.z..")")
    end
end)

concommand.Add("ix_debug_getattachments", function(ply)
    local ent = ply:GetEyeTrace().Entity
    if not ( ent and IsValid(ent) ) then
        print("Invalid entity")
        return
    end
    
    PrintTable(ent:GetAttachments())
end)

sound.Add({
    name = "Helix.Whoosh",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 80,
    pitch = {90, 105},
    sound = "",
})

sound.Add({
    name = "Helix.Rollover",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 80,
    pitch = 120,
    sound = "",
})

sound.Add({
    name = "Helix.Press",
    channel = CHAN_STATIC,
    volume = 0.8,
    level = 80,
    pitch = 100,
    sound = "projectparagon/sfx/Interact/Button.ogg",
})

sound.Add({
    name = "Helix.Notify",
    channel = CHAN_STATIC,
    volume = 0.2,
    level = 80,
    pitch = 100,
    sound = "projectparagon/sfx/Interact/Button2.ogg",
})

surface.CreateFont("ParagonMenuButton", {
    font = "Courier New",
    size = 56,
    weight = 500,
})


local SCHEMA = Schema
SCHEMA.UI = SCHEMA.UI or {}
SCHEMA.UI.Fonts = SCHEMA.UI.Fonts or {}
SCHEMA.UI.BaseFontName = "Courier New"

function SCHEMA.UI:RegisterFont(name, data)
    surface.CreateFont(name, data)
    SCHEMA.UI.Fonts[name] = {
        name = name,
        data = data,
    }
end

function SCHEMA.UI:LoadCustomFonts()
    MsgC(ix.config.Get("color", Color(0, 150, 255)), "[Paragon UI] Loading custom fonts...\n")

    for i = 1, 15 do
        local size = i * 5
        SCHEMA.UI:RegisterFont("ParagonFont_Elements_"..size, {
            font = SCHEMA.UI.BaseFontName,
            size = size,
            antialias = true,
        })

        SCHEMA.UI:RegisterFont("ParagonFont_Elements_Italic_"..size, {
            font = SCHEMA.UI.BaseFontName,
            size = size,
            antialias = true,
            italic = true,
        })

        SCHEMA.UI:RegisterFont("ParagonFont_Elements_Bold_"..size, {
            font = SCHEMA.UI.BaseFontName,
            size = size,
            antialias = true,
            weight = 1000,
        })
    end

    for i = 3, 20 do
        local scaledSize = ScreenScale(i * 2)
        SCHEMA.UI:RegisterFont("ParagonFont_Elements_ScreenScale_".. (i*2), {
            font = SCHEMA.UI.BaseFontName,
            size = scaledSize,
            antialias = true,
        })

        SCHEMA.UI:RegisterFont("ParagonFont_Elements_Italic_ScreenScale_".. (i*2), {
            font = SCHEMA.UI.BaseFontName,
            size = scaledSize,
            antialias = true,
            italic = true,
        })

        SCHEMA.UI:RegisterFont("ParagonFont_Elements_Bold_ScreenScale_".. (i*2), {
            font = SCHEMA.UI.BaseFontName,
            size = scaledSize,
            antialias = true,
            weight = 1000,
        })
    end

    MsgC(ix.config.Get("successColor", Color(0, 255, 0)), "[Paragon UI] Custom fonts loaded.\n")
end

hook.Add("OnCharacterMenuCreated", "Paragon_PlayCharMenuMusic", function(panel)
    sound.PlayFile("sound/projectparagon/sfx/Music/loading_complete_music.wav", "noplay", function(channel, errorID, errorName)
        if (channel) then
            channel:SetVolume(ix.config.Get("musicVolume", 0.5))
            channel:Play()
        elseif (errorID) then
            MsgC(ix.config.Get("errorColor", Color(255, 0, 0)), "[Paragon UI] Failed to play character menu sound: \""..errorName.."\". Error ID: "..errorID.."\n")
        end
    end)
end)

concommand.Add("paragon_loadfonts", function()
    SCHEMA.UI:LoadCustomFonts()
end)

concommand.Add("paragon_getfonts", function()
    MsgC(ix.config.Get("color", Color(0, 150, 255)), "[Paragon UI] Stored Custom Fonts:\n")
    if (SCHEMA.UI.Fonts and table.Count(SCHEMA.UI.Fonts) > 0) then
        for fontName, fontData in SortedPairs(SCHEMA.UI.Fonts) do
            MsgC(color_white, " - " .. fontName .. " (Size: " .. fontData.data.size .. ")\n")
        end
    else
        MsgC(color_white, "No custom fonts currently stored or loaded by Paragon UI.\n")
    end
end)

if (SCHEMA.UI.LoadCustomFonts) then
    SCHEMA.UI:LoadCustomFonts()
else
    MsgC(ix.config.Get("errorColor", Color(255,0,0)), "[Paragon UI] Error: LoadCustomFonts function not found!\n")
end