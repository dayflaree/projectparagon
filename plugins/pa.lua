local PLUGIN = PLUGIN or {}
PLUGIN.name = "Passive Announcements"
PLUGIN.author = "dayflare"
PLUGIN.description = "Plays random global audio announcements with chat messages on a configurable delay."

-- Add configuration option to enable/disable the PA system
ix.config.Add("paSystemEnabled", true, "Whether or not the PA System announcements are enabled.", nil, {
    category = "Passive Announcements"
})

-- Configuration: List of announcements with audio files and chat messages
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
        message = "Attention, Site Director Rosewood. Please report to administration complex."
    }
    -- Add more announcements here as needed
}

-- Configurable delay range in seconds (min and max)
PLUGIN.minDelay = 300 -- 5 minutes
PLUGIN.maxDelay = 600 -- 10 minutes

-- Store announcements locally to prevent reference loss
local announcements = PLUGIN.announcements
local minDelay = PLUGIN.minDelay
local maxDelay = PLUGIN.maxDelay

-- Create a PA system chat type
function PLUGIN:InitializedChatClasses()
    -- Register a special chat class for PA system
    ix.chat.Register("pa_system", {
        color = Color(255, 150, 0),
        format = "[PA System] %s",
        GetColor = function(self, speaker, text)
            return self.color
        end,
        CanHear = function(self, speaker, listener)
            return true -- Everyone can hear PA announcements
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            chat.AddText(self.color, "[PA System] ", Color(255, 255, 255), text)
        end
    })
end

if (SERVER) then
    -- Variable to store the timer identifier
    local paTimerIdentifier = "ix.paSystem.nextAnnouncement"
    
    -- Function to play an announcement
    local function PlayAnnouncement()
        -- Always check if PA system is enabled before proceeding
        if not ix.config.Get("paSystemEnabled") then
            -- System is disabled, schedule a check after 60 seconds to see if it's been re-enabled
            timer.Create(paTimerIdentifier, 60, 1, function()
                -- When we check again, validate the config again
                if ix.config.Get("paSystemEnabled") then
                    PlayAnnouncement()
                else
                    -- Still disabled, check again later
                    timer.Create(paTimerIdentifier, 60, 1, PlayAnnouncement)
                end
            end)
            return
        end
        
        -- Pick a random announcement from the list
        local announcement = announcements[math.random(1, #announcements)]
        
        if not announcement then
            print("[PassiveAnnouncements] No announcements defined!")
            return
        end
        
        -- Play the sound globally
        BroadcastLua('surface.PlaySound("' .. announcement.sound .. '")')
        
        -- Send the chat message to all players using a special format
        for _, player in pairs(player.GetAll()) do
            ix.chat.Send(player, "pa_system", announcement.message)
        end
        
        -- Log it for debugging
        print("[PassiveAnnouncements] Played: " .. announcement.sound .. " - " .. announcement.message)
        
        -- Schedule the next announcement with a random delay
        local delay = math.random(minDelay, maxDelay)
        timer.Create(paTimerIdentifier, delay, 1, PlayAnnouncement)
    end
    
    -- Start the announcement system when the plugin loads
    function PLUGIN:InitializedPlugins()
        -- Clean up any existing timers
        if timer.Exists(paTimerIdentifier) then
            timer.Remove(paTimerIdentifier)
        end
        
        -- Initial delay before the first announcement
        local initialDelay = math.random(minDelay, maxDelay)
        
        -- Only start the system if it's enabled
        if ix.config.Get("paSystemEnabled") then
            print("[PassiveAnnouncements] Starting with initial delay of " .. initialDelay .. " seconds")
            timer.Create(paTimerIdentifier, initialDelay, 1, PlayAnnouncement)
        else
            print("[PassiveAnnouncements] PA System is disabled via configuration")
        end
    end
    
    -- Handle configuration changes
    function PLUGIN:OnConfigChanged(key, oldValue, newValue)
        if key == "paSystemEnabled" then
            print("[PassiveAnnouncements] Configuration changed: " .. tostring(key) .. " = " .. tostring(newValue))
            
            if newValue then
                -- System was disabled and is now enabled
                if not timer.Exists(paTimerIdentifier) then
                    local delay = math.random(minDelay, maxDelay)
                    print("[PassiveAnnouncements] PA System enabled - starting with delay of " .. delay .. " seconds")
                    timer.Create(paTimerIdentifier, delay, 1, PlayAnnouncement)
                end
            else
                -- System was enabled and is now disabled
                if timer.Exists(paTimerIdentifier) then
                    print("[PassiveAnnouncements] PA System disabled - stopping announcements")
                    timer.Remove(paTimerIdentifier)
                end
            end
        end
    end
    
    -- Add a command to toggle the PA system (optional, for testing)
    ix.command.Add("patoggle", {
        description = "Toggles the PA System announcements.",
        adminOnly = true,
        OnRun = function(self, client)
            local currentValue = ix.config.Get("paSystemEnabled")
            ix.config.Set("paSystemEnabled", not currentValue)
            
            return "PA System has been " .. (not currentValue and "enabled" or "disabled") .. "."
        end
    })
end

return PLUGIN