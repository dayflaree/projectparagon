local PLUGIN = PLUGIN

function PLUGIN:Think()
    if ( self.nextThink and self.nextThink > CurTime() ) then
        return
    end

    local schedules = self.schedules
    local time = StormFox2.Time.Get(true)

    for k, v in pairs(schedules) do
        if ( time == v.on and GetGlobalInt("ixScheduleCurrent", 1) != k ) then
            hook.Run("OnScheduleChanged", k, v, true)
        elseif ( time == v.off and GetGlobalInt("ixScheduleCurrent", 1) == k ) then
            hook.Run("OnScheduleChanged", k, v, false)
        end
    end

    self.nextThink = CurTime() + 0.33
end

function PLUGIN:OnScheduleChanged(key, schedule, bStart)
    if ( SERVER ) then
        local onTrigger = bStart and schedule.onStart or schedule.onEnd
        if ( onTrigger ) then
            onTrigger(schedule)
        end
    else
        local onTrigger = bStart and schedule.onClientStart or schedule.onClientEnd
        if ( onTrigger ) then
            onTrigger(schedule)
        end
    end

    if ( SERVER ) then
        ix.log.AddRaw("Schedule " .. schedule.name .. " has " .. (bStart and "started" or "ended") .. " at " .. StormFox2.Time.TimeToString())
    end
    
    SetGlobalInt("ixScheduleCurrent", bStart and key or 1)
end