local PLUGIN = PLUGIN or {}

PLUGIN.name        = "Passive Announcements"
PLUGIN.author      = "dayflare"
PLUGIN.description = "Plays random global audio announcements with chat messages on a configurable delay."

PLUGIN.announcements = {
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement1.ogg", message = "Don't forget, today is pizza day, so head on down to the cafeteria to grab yourself a hot slice!" },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement2.ogg", message = "Remember, security is the first step towards a safe work environment! Stay secure, stay vigilant." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement3.ogg", message = "A reminder, to all personnel: Motivational seminars are held at the faculty auditorium from hours 17 to 18 on Thursdays! Come on down and get motivated!" },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement4.ogg", message = "Remember to report all suspicious activity to your supervisors. Not even you are exempt from scrutiny. Stay paranoid, stay vigilant." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement5.ogg", message = "Feeling out of shape? Drop by the faculty gymnasium and feel free to participate in a game of community badminton on sundays!" },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement6.ogg", message = "Feel tired and overworked? Freshly brewed coffee is served at the cafeteria at all hours." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/announcement7.ogg", message = "Come down and join our annual movie night this saturday! This years film: 'Area 51: Panic and Terror 2 miles under'!" },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted1.ogg", message = "Attention, Security Chief Franklin. Please report to containment chamber 1-7-3 immediately." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted2.ogg", message = "Doctor L. Please report to Heavy Containment Checkpoint C." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted3.ogg", message = "Attention, Doctor Maynard. Report to administrations office immediately." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted4.ogg", message = "Maintenance Crew Alpha, report to Light Containment elevator 6A for safety inspection." },
    { sound = "projectparagon/sfx/Room/Intro/PA/scripted/scripted5.ogg", message = "Attention, Site Director Rosewood. Please report to administrations complex." }
}

PLUGIN.minDelay = 30
PLUGIN.maxDelay = 60

PLUGIN.mtfThreshold = 10 -- Players
PLUGIN.mtfSound = "projectparagon/sfx/Character/MTF/Announc.ogg"
PLUGIN.mtfMessage = "Mobile Task Force Unit Epsilon-11, designated Nine-Tailed Fox, has entered the facility. All remaining survivors are advised to stay in the evacuation shelter, or any other safe area until the unit has secured the facility. We'll start escorting personnel out when the escaped SCP´s have been re-contained."

PLUGIN.ciThreshold = 10 -- Players
PLUGIN.ciSound = "projectparagon/sfx/Character/MTF/AnnouncChaosRaid.mp3"
PLUGIN.ciMessage = "Attention all security personnel, Chaos Insurgents have entered Sector 1. Your objective is to suppress the Chaos Insurgent raid."

local announcements = PLUGIN.announcements
local minDelay      = PLUGIN.minDelay
local maxDelay      = PLUGIN.maxDelay

local mtfTriggered = false
local ciTriggered = false
local lastFactionTriggerTime = 0
local nextFactionCheck = 0

function PLUGIN:Load()
    if (ix.config and ix.config.Add and ix.config.IsConfigVar) then
        if not ix.config.IsConfigVar("paSystemEnabled") then
            ix.config.Add("paSystemEnabled", true, "Whether or not the PA System announcements are enabled.", nil, {
                category = "Passive Announcements"
            })
        end
    end
end

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("pa_system", {
        color     = Color(255, 150, 0),
        format    = "[PA System] %s",
        indicator = "none",
        CanHear   = function(speaker, listener) return true end,
        OnChatAdd = function(chatClass, speaker, text)
            chat.AddText(chatClass.color, "[PA System] ", color_white, text)
        end
    })
end

if SERVER then
    util.AddNetworkString("ixPASound")
    local timerName = "ix.Paragon.PASystem.NextAnnouncement"

    local function scheduleNextRegularAnnouncement(delay)
        timer.Create(timerName, delay, 1, function()
            if not timer.Exists(timerName) then return end
            PLUGIN:PlayRegularAnnouncement()
        end)
    end

    function PLUGIN:PlayRegularAnnouncement()
        if not ix.config.Get("paSystemEnabled", true) then
            scheduleNextRegularAnnouncement(60)
            return
        end

        if (CurTime() - lastFactionTriggerTime < 30) then
            scheduleNextRegularAnnouncement(30)
            return
        end

        if (#announcements == 0) then
            print("[PassiveAnnouncements] No regular announcements defined!")
            return
        end
        local ann = announcements[math.random(#announcements)]

        local allPlayers = player.GetAll()
        if #allPlayers > 0 then
            -- CORRECTED: Send "from" the first player in the list.
            -- The pa_system chat class will handle display for everyone.
            ix.chat.Send(allPlayers[1], "pa_system", ann.message)
        end

        net.Start("ixPASound")
            net.WriteString(ann.sound)
        net.Broadcast()

        scheduleNextRegularAnnouncement(math.random(minDelay, maxDelay))
    end

    function PLUGIN:InitPostEntity()
        if timer.Exists(timerName) then
            timer.Remove(timerName)
        end

        if ix.config.Get("paSystemEnabled", true) then
            local initialDelay = math.random(minDelay, maxDelay)
            scheduleNextRegularAnnouncement(initialDelay)
        end
    end

    function PLUGIN:OnConfigChanged(key, oldValue, newValue)
        if key ~= "paSystemEnabled" then return end

        if newValue == true then
            if not timer.Exists(timerName) then
                local delay = math.random(minDelay, maxDelay)
                scheduleNextRegularAnnouncement(delay)
            end
        else
            if timer.Exists(timerName) then
                timer.Remove(timerName)
            end
        end
    end

    ix.command.Add("patoggle", {
        description = "Toggles the Passive Announcement System.",
        adminOnly   = true,
        OnRun       = function(selfCmd, client)
            local currentValue = ix.config.Get("paSystemEnabled", true)
            local newValue = not currentValue
            ix.config.Set("paSystemEnabled", newValue)
            local message = "Passive Announcement System has been " .. (newValue and "ENABLED" or "DISABLED") .. "."
            if IsValid(client) then client:Notify(message) end
            return message
        end
    })

    hook.Add("Think", "Paragon_FactionAnnouncementCheck", function()
        if CurTime() < nextFactionCheck then return end
        nextFactionCheck = CurTime() + 5

        if not ix.config.Get("paSystemEnabled", true) then return end

        local mtfCount, ciCount = 0, 0
        local allPlayers = player.GetAll()
        if #allPlayers == 0 then return end

        for _, ply in ipairs(allPlayers) do
            if IsValid(ply) and ply:Team() ~= TEAM_UNASSIGNED and ply:Team() ~= TEAM_SPECTATOR then
                local factionTable = ix.faction.Get(ply:Team())
                if factionTable then
                    if factionTable.uniqueID == FACTION_MTF then
                        mtfCount = mtfCount + 1
                    elseif factionTable.uniqueID == FACTION_CI then
                        ciCount = ciCount + 1
                    end
                end
            end
        end

        if mtfCount >= PLUGIN.mtfThreshold and not mtfTriggered then
            if (CurTime() - lastFactionTriggerTime < 60) then return end
            mtfTriggered = true
            ciTriggered = false
            lastFactionTriggerTime = CurTime()

            if #allPlayers > 0 then
                -- CORRECTED: Send "from" the first player.
                ix.chat.Send(allPlayers[1], "pa_system", PLUGIN.mtfMessage)
            end
            net.Start("ixPASound")
                net.WriteString(PLUGIN.mtfSound)
            net.Broadcast()

            if timer.Exists(timerName) then timer.Remove(timerName) end
            scheduleNextRegularAnnouncement(math.max(60, minDelay))

        elseif mtfCount < PLUGIN.mtfThreshold and mtfTriggered then
            mtfTriggered = false
        end

        if not mtfTriggered and ciCount >= PLUGIN.ciThreshold and not ciTriggered then
            if (CurTime() - lastFactionTriggerTime < 60) then return end
            ciTriggered = true
            lastFactionTriggerTime = CurTime()

            if #allPlayers > 0 then
                -- CORRECTED: Send "from" the first player.
                ix.chat.Send(allPlayers[1], "pa_system", PLUGIN.ciMessage)
            end
            net.Start("ixPASound")
                net.WriteString(PLUGIN.ciSound)
            net.Broadcast()

            if timer.Exists(timerName) then timer.Remove(timerName) end
            scheduleNextRegularAnnouncement(math.max(60, minDelay))

        elseif not mtfTriggered and ciCount < PLUGIN.ciThreshold and ciTriggered then
            ciTriggered = false
        end
    end)
end -- END OF if SERVER then

if CLIENT then
    net.Receive("ixPASound", function()
        local soundPath = net.ReadString()

        if (ix.gui.characterMenu and IsValid(ix.gui.characterMenu) and ix.gui.characterMenu:IsVisible()) then
            return
        end

        surface.PlaySound(soundPath)
    end)
end