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
    "attempts to activate the scanner, but the system remains idle, unresponsive to the lack of a keycard.",
    "attempts to interact with the button, but without a keycard, the scanner remains unresponsive.",
    "frantically taps the button, but with no keycard in hand, the scanner doesn't react.",
    "gives the button a hopeful tap, but it remains silent, requiring a keycard to function.",
    "places their hand over the reader, but without a keycard, the system ignores the input.",
    "presses the button, but nothing happens as they realize they have no keycard.",
    "pushes the button with an empty hand, only to be met with silence from the scanner.",
    "swipes at the scanner with nothing but air, the button refusing to respond without a keycard.",
    "tries pressing the button repeatedly, but without a card, the scanner shows no sign of activity.",
    "waves their hand near the scanner, but without a keycard, there's no response from the button."
}

PLUGIN.messagesDeniedCard = {
    "carefully swipes their keycard through the slot, but the scanner buzzes in refusal, emitting a sharp beep.",
    "confidently slides their keycard through, but the red light blares and the terminal stays silent, followed by a denying beep.",
    "holds their keycard up to the scanner, eyes narrowing as the red light blinks twice before a loud beep denies access.",
    "inserts their keycard into the slot, but the mechanism clicks and rejects it with an abrupt beep.",
    "presses the keycard against the reader, waiting, only for the system to buzz and beep in denial.",
    "runs the keycard through the scanner, but the terminal flashes red, followed by an echoing denial beep.",
    "slides their keycard through the reader precisely, but the indicator blinks red, with an error tone beeping sharply.",
    "swipes the keycard urgently, watching in frustration as the reader's light flickers red before denying with a beep.",
    "tries once more, sliding their keycard slowly, but the system remains unresponsive, rejecting access with a beep.",
    "with a shaky hand, they swipe their keycard, only to be met with the unmistakable red flash and a denying beep."
}

PLUGIN.messagesAllowed = {
    "after sliding the keycard smoothly through the reader, the scanner emits a soft beep as the light turns green.",
    "holds their keycard to the reader, a small green light appears, accompanied by a quiet, confirming beep.",
    "places their keycard against the reader, waiting as the light flickers green with a faint beep of approval.",
    "runs their keycard through the reader, and after a brief pause, the system hums, emitting a low beep as the light turns green.",
    "runs their keycard through the slot, the terminal responds with a green light and a soft beep of clearance.",
    "slides their keycard through the scanner, and a green light appears, followed by a confirming beep.",
    "swipes their keycard smoothly, watching as the scanner glows green, followed by a quick beep of approval.",
    "takes a deep breath and swipes their keycard; the scanner responds with a beep and a green light.",
    "taps their keycard against the reader, waiting for the green light and the soft beep that confirms access.",
    "with a subtle swipe of their keycard, they hear a soft beep as the light shifts to green, indicating successful access."
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