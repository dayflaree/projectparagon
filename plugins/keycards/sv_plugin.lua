local PLUGIN = PLUGIN

function PLUGIN:PlayerUse(ply, ent)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ent:GetClass() == "func_button" and ix.keycards.GetLevel(ent) and ix.keycards.GetLevel(ent).buttonLevel ) then
        if ( ply:GetAccessLevel() >= ix.keycards.GetLevel(ent).buttonLevel ) then
            ent:EmitSound("minerva/scprp/interact/keycard01.mp3")
        else
            ent:EmitSound("minerva/scprp/interact/keycard02.mp3")

            return false
        end
    end
end

function PLUGIN:LoadData()
    for k, v in pairs(ents.FindByClass("func_button")) do
        v.level = ix.data.Get("doorlevels/"..v:MapCreationID(), {})
    end
end

function ix.keycards.GetLevel(ent)
    return ent.level or ix.data.Get("doorlevels/"..ent:MapCreationID(), {})
end

function ix.keycards.SetLevel(ent, level)
    if not ( level and level >= 1 and level <= 6 ) then
        print("Invalid Level!")
        return false
    end

    if not ( IsValid(ent) and ent:GetClass() == "func_button" ) then
        print("Invalid Target!")
        return false
    end

    ent.level = {
        buttonLevel = level,
    }
    ix.data.Set("doorlevels/"..ent:MapCreationID(), ent.level)
end