local PLUGIN = PLUGIN or {}
PLUGIN.name = "Passive Announcements"
PLUGIN.author = "dayflare"
PLUGIN.description = "Plays random global audio announcements with chat messages on a configurable delay."

-- Configuration: List of announcements with audio files and chat messages
PLUGIN.announcements = {
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement1.ogg", -- Replace with your actual sound file path
        message = "Don't forget, today is pizza day, so head on down to the cafeteria to grab yourself a hot slice!"
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement2.ogg",
        message = "Remember, security is the first step towards a safe work environment! Stay secure, stay vigilant."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement3.ogg",
        message = "A reminder, to all personnel: Motivational seminars are held at the faculty auditorium from hours 17 to 18 on Thursdays! Come on down and get motivated!"
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement4.ogg",
        message = "Remember to report all suspicious activity to your supervisors. Not even you are exempt from scrutiny. Stay paranoid, stay vigilant."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement5.ogg",
        message = "Feeling out of shape? Drop by the faculty gymnasium and feel free to participate in a game of community badminton on sundays!"
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement6.ogg",
        message = "Feel tired and overworked? Freshly brewed coffee is served at the cafeteria at all hours."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/announcement7.ogg",
        message = "Come down and join our annual movie night this saturday! This years film: 'Area 51: Panic and Terror 2 miles under'!"
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/scripted1.ogg",
        message = "Attention, Security Chief Franklin. Please report to containment chamber 1-7-3 immediately."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/scripted2.ogg",
        message = "Doctor L. Please report to Heavy Containment Checkpoint C."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/scripted3.ogg",
        message = "Attention, Doctor Maynard. Report to administrations office immediately."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/scripted4.ogg",
        message = "Maintenance Crew Alpha, report to Light Containment elevator 6A for safety inspection."
    },
    {
        sound = "projectparagon/gamesounds/scpcb/room/intro/pa/scripted/scripted5.ogg",
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
    -- Function to play an announcement
    local function PlayAnnouncement()
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
        timer.Simple(delay, PlayAnnouncement)
    end
    
    -- Start the announcement system when the plugin loads
    function PLUGIN:InitializedPlugins()
        -- Initial delay before the first announcement
        local initialDelay = math.random(minDelay, maxDelay)
        timer.Simple(initialDelay, PlayAnnouncement)
        print("[PassiveAnnouncements] Started with initial delay of " .. initialDelay .. " seconds")
    end
end

return PLUGIN