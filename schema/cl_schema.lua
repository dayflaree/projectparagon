-- Here is where all clientside functions should go.
local menu = ix.util.GetMaterial("90/projectparagon/ui/menu/menu_black.png")
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
    sound = "projectparagon/gamesounds/scpcb/interact/button.ogg",
})

sound.Add({
    name = "Helix.Notify",
    channel = CHAN_STATIC,
    volume = 0.2,
    level = 80,
    pitch = 100,
    sound = "projectparagon/gamesounds/scpcb/interact/button2.ogg",
})