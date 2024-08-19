local PLUGIN = PLUGIN

PLUGIN.name = "Keycards"
PLUGIN.description = "Implements a keycard system for doors, very similar to SCP Containment Breach."
PLUGIN.author = "Riggs"

PLUGIN.accessLevels = {
    ["key6"] = 6,
    ["key5"] = 5,
    ["key4"] = 4,
    ["key3"] = 3,
    ["key2"] = 2,
    ["key1"] = 1,
}

PLUGIN.messagesDenied = {
    "attempts to swipe their keycard on the button, but it doesn't work.",
    "swipes their keycard on the button, with no success.",
}

PLUGIN.messagesAllowed = {
    "swipes their keycard on the button, and it works.",
    "uses their keycard on the button with success.",
}

function PLUGIN:IsValidLevel(level)
    if ( !level ) then
        return false, "You have not provided a valid level!"
    end

    if ( !isnumber(level) ) then
        return false, "The level must be a number!"
    end

    if ( level < 1 ) then
        return false, "The level must be greater than 0!"
    end

    if ( level > 6 ) then
        return false, "The level must be less than or equal to 6!"
    end

    return true
end

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.util.IncludeDir(PLUGIN.folder .. "/meta", true)

ix.command.Add("SetKeycardLevel", {
    description = "Set's the keycard level of a button.",
    adminOnly = true,
    arguments = {
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, ply, level)
        local trace = ply:GetEyeTrace()
        for k, v in ipairs(ents.FindInSphere(trace.HitPos, 32)) do
            if ( v:GetClass() == "func_button" ) then
                target = v
                break
            end
        end

        if ( !IsValid(target) or target:GetClass() != "func_button" ) then
            return false, "You must be looking near a button!"
        end

        local can, reason = PLUGIN:IsValidLevel(level)
        if ( !can ) then
            return reason or "You must provide a valid level!"
        end

        PLUGIN:SetLevel(target, level)
        ply:Notify("You have set the keycard level of " .. target:GetName() .. " to " .. level .. ".")
    end
})

ix.command.Add("RemoveKeycardLevel", {
    description = "Removes the keycard level of a button.",
    adminOnly = true,
    OnRun = function(self, ply)
        local trace = ply:GetEyeTrace()
        for k, v in ipairs(ents.FindInSphere(trace.HitPos, 32)) do
            if ( v:GetClass() == "func_button" ) then
                target = v
                break
            end
        end

        if ( !IsValid(target) or target:GetClass() != "func_button" ) then
            return false, "You must be looking near a button!"
        end

        PLUGIN:SetLevel(target, 0)
        ply:Notify("You have removed the keycard level of " .. target:GetName() .. ".")
    end
})