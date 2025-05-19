-- gamemodes/projectparagon/plugins/passive_announcements.lua
local PLUGIN = PLUGIN or {}

PLUGIN.name        = "Passive Announcements"
PLUGIN.author      = "dayflare"
PLUGIN.description = "Plays random global audio announcements with chat messages on a configurable delay."

-- Configuration option to enable/disable the PA system
ix.config.Add("paSystemEnabled", true, "Whether or not the PA System announcements are enabled.", nil, {
    category = "Passive Announcements"
})

-- List of announcements: sound path + chat message
PLUGIN.announcements = {
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement1.ogg", -- Replace with your actual sound file path
        message = "Don't forget, today is pizza day, so head on down to the cafeteria to grab yourself a hot slice!"
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement2.ogg",
        message = "Remember, security is the first step towards a safe work environment! Stay secure, stay vigilant."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement3.ogg",
        message = "A reminder, to all personnel: Motivational seminars are held at the faculty auditorium from hours 17 to 18 on Thursdays! Come on down and get motivated!"
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement4.ogg",
        message = "Remember to report all suspicious activity to your supervisors. Not even you are exempt from scrutiny. Stay paranoid, stay vigilant."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement5.ogg",
        message = "Feeling out of shape? Drop by the faculty gymnasium and feel free to participate in a game of community badminton on sundays!"
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement6.ogg",
        message = "Feel tired and overworked? Freshly brewed coffee is served at the cafeteria at all hours."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement7.ogg",
        message = "Come down and join our annual movie night this saturday! This years film: 'Area 51: Panic and Terror 2 miles under'!"
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted1.ogg",
        message = "Attention, Security Chief Franklin. Please report to containment chamber 1-7-3 immediately."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted2.ogg",
        message = "Doctor L. Please report to Heavy Containment Checkpoint C."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted3.ogg",
        message = "Attention, Doctor Maynard. Report to administrations office immediately."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted4.ogg",
        message = "Maintenance Crew Alpha, report to Light Containment elevator 6A for safety inspection."
    },
    {
        sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted5.ogg",
        message = "Attention, Site Director Rosewood. Please report to administrations complex."
    }
}

-- Delay range in seconds
PLUGIN.minDelay = 300  -- 5 minutes
PLUGIN.maxDelay = 600  -- 10 minutes

local announcements = PLUGIN.announcements
local minDelay      = PLUGIN.minDelay
local maxDelay      = PLUGIN.maxDelay

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("pa_system", {
        color     = Color(255, 150, 0),
        format    = "[PA System] %s",
        indicator = "none",
        CanHear   = function() return true end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(self.color, "[PA System] ", Color(255,255,255), text)
        end
    })
end

if SERVER then
    util.AddNetworkString("ixPASound")
    local timerName = "ix.paSystem.nextAnnouncement"

    local function scheduleNext(delay)
        timer.Create(timerName, delay, 1, function()
            PLUGIN:PlayAnnouncement()
        end)
    end

    function PLUGIN:PlayAnnouncement()
        if not ix.config.Get("paSystemEnabled") then
            -- Retry in 60s if disabled
            timer.Create(timerName, 60, 1, function()
                if ix.config.Get("paSystemEnabled") then
                    PLUGIN:PlayAnnouncement()
                else
                    scheduleNext(60)
                end
            end)
            return
        end

        local ann = announcements[math.random(#announcements)]
        if not ann then
            print("[PassiveAnnouncements] No announcements defined!")
            return
        end

        -- 1) Send chat once
        local allPlayers = player.GetAll()
        if #allPlayers > 0 then
            ix.chat.Send(allPlayers[1], "pa_system", ann.message)
        end

        -- 2) Broadcast net to play the sound on each client
        net.Start("ixPASound")
            net.WriteString(ann.sound)
        net.Broadcast()

        print(("[PassiveAnnouncements] Played: %s – %s"):format(ann.sound, ann.message))

        -- Schedule next
        scheduleNext(math.random(minDelay, maxDelay))
    end

    function PLUGIN:InitPostEntity()
        if timer.Exists(timerName) then
            timer.Remove(timerName)
        end

        if ix.config.Get("paSystemEnabled") then
            local initial = math.random(minDelay, maxDelay)
            print("[PassiveAnnouncements] Starting with initial delay of " .. initial .. " seconds")
            scheduleNext(initial)
        else
            print("[PassiveAnnouncements] PA System is disabled via configuration")
        end
    end

    function PLUGIN:OnConfigChanged(key, oldValue, newValue)
        if key ~= "paSystemEnabled" then return end

        if newValue then
            if not timer.Exists(timerName) then
                local d = math.random(minDelay, maxDelay)
                print("[PassiveAnnouncements] Enabled – scheduling in " .. d .. "s")
                scheduleNext(d)
            end
        else
            if timer.Exists(timerName) then
                print("[PassiveAnnouncements] Disabled – stopping announcements")
                timer.Remove(timerName)
            end
        end
    end

    ix.command.Add("patoggle", {
        description = "Toggles the PA System announcements.",
        adminOnly   = true,
        OnRun       = function(self, client)
            local val = not ix.config.Get("paSystemEnabled")
            ix.config.Set("paSystemEnabled", val)
            return "PA System has been " .. (val and "enabled" or "disabled") .. "."
        end
    })

    return
end

-- CLIENT
net.Receive("ixPASound", function()
    local soundPath = net.ReadString()

    -- If the Helix main menu panel is open, skip
    if ix.gui.characterMenu and IsValid(ix.gui.characterMenu) and ix.gui.characterMenu:IsVisible() then
        return
    end

    surface.PlaySound(soundPath)
end)

return PLUGIN
