local PLUGIN = PLUGIN or {}

PLUGIN.name        = "Passive Announcements"
PLUGIN.author      = "dayflare"
PLUGIN.description = "Plays random global audio announcements with chat messages on a configurable delay."

ix.config.Add("paSystemEnabled", true, "Whether or not the PA System announcements are enabled.", nil, {
    category = "Passive Announcements"
})

PLUGIN.announcements = {
    -- [same list of announcements as before... unchanged]
}

-- Delay range in seconds
PLUGIN.minDelay = 300  -- 5 minutes
PLUGIN.maxDelay = 600  -- 10 minutes

-- Faction-specific announcements
PLUGIN.mtfThreshold = 10
PLUGIN.mtfSound = "projectparagon/sfx/Character/MTF/Announc.ogg"
PLUGIN.mtfMessage = "Mobile Task Force Unit Epsilon-11, designated Nine-Tailed Fox, has entered the facility. All remaining survivors are advised to stay in the evacuation shelter, or any other safe area until the unit has secured the facility. We'll start escorting personnel out when the escaped SCP´s have been re-contained."

PLUGIN.ciThreshold = 10
PLUGIN.ciSound = "projectparagon/sfx/Character/MTF/AnnouncChaosRaid.mp3"
PLUGIN.ciMessage = "Attention all security personnel, Chaos Insurgents have entered Sector 1. Your objective is to suppress the Chaos Insurgent raid."

local announcements = PLUGIN.announcements
local minDelay      = PLUGIN.minDelay
local maxDelay      = PLUGIN.maxDelay

local mtfTriggered = false
local ciTriggered = false
local lastFactionTriggerTime = 0
local nextFactionCheck = 0

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
        if not ix.config.Get("paSystemEnabled") or (CurTime() - lastFactionTriggerTime < 30) then
            -- Retry in 60s if disabled or cooldown active
            timer.Create(timerName, 60, 1, function()
                if ix.config.Get("paSystemEnabled") and (CurTime() - lastFactionTriggerTime >= 30) then
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

        local allPlayers = player.GetAll()
        if #allPlayers > 0 then
            ix.chat.Send(allPlayers[1], "pa_system", ann.message)
        end

        net.Start("ixPASound")
            net.WriteString(ann.sound)
        net.Broadcast()

        print(("[PassiveAnnouncements] Played: %s – %s"):format(ann.sound, ann.message))
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

    hook.Add("Think", "ix.FactionAnnouncementCheck", function()
        if CurTime() < nextFactionCheck then return end
        nextFactionCheck = CurTime() + 5

        local mtfCount, ciCount = 0, 0

        for _, ply in ipairs(player.GetAll()) do
            local faction = ix.faction.Get(ply:Team())
            if faction then
                if faction.name == "Mobile Task Force" then
                    mtfCount = mtfCount + 1
                elseif faction.name == "Chaos Insurgency" then
                    ciCount = ciCount + 1
                end
            end
        end

        -- MTF Check
        if mtfCount >= PLUGIN.mtfThreshold and not mtfTriggered then
            mtfTriggered = true
            lastFactionTriggerTime = CurTime()

            if #player.GetAll() > 0 then
                ix.chat.Send(player.GetAll()[1], "pa_system", PLUGIN.mtfMessage)
            end

            net.Start("ixPASound")
                net.WriteString(PLUGIN.mtfSound)
            net.Broadcast()

            print("[PassiveAnnouncements] MTF Entry triggered.")
        elseif mtfCount < PLUGIN.mtfThreshold and mtfTriggered then
            mtfTriggered = false
            print("[PassiveAnnouncements] MTF count dropped. Reset.")
        end

        -- CI Check
        if ciCount >= PLUGIN.ciThreshold and not ciTriggered then
            ciTriggered = true
            lastFactionTriggerTime = CurTime()

            if #player.GetAll() > 0 then
                ix.chat.Send(player.GetAll()[1], "pa_system", PLUGIN.ciMessage)
            end

            net.Start("ixPASound")
                net.WriteString(PLUGIN.ciSound)
            net.Broadcast()

            print("[PassiveAnnouncements] CI Entry triggered.")
        elseif ciCount < PLUGIN.ciThreshold and ciTriggered then
            ciTriggered = false
            print("[PassiveAnnouncements] CI count dropped. Reset.")
        end
    end)
end

-- CLIENT
net.Receive("ixPASound", function()
    local soundPath = net.ReadString()

    if ix.gui.characterMenu and IsValid(ix.gui.characterMenu) and ix.gui.characterMenu:IsVisible() then
        return
    end

    surface.PlaySound(soundPath)
end)

return PLUGIN
