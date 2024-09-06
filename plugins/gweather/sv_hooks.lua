local PLUGIN = PLUGIN

function PLUGIN:WeatherGetRandom()
    local total = 0

    for _, v in ipairs(self.types) do
        total = total + ( v.chance or 1 )
    end

    local choice = math.random(0, total)
    local current = 0

    for _, v in ipairs(self.types) do
        current = current + ( v.chance or 1 )

        if ( choice <= current ) then
            return v
        end
    end

    return self.types[1]
end

function PLUGIN:WeatherStart(weather)
    if ( !weather ) then return end

    local duration = ix.config.Get("weatherDuration", 300)

    hook.Run("WeatherEnd")

    local class = weather[2]
    if ( istable(class) ) then
        for _, v in ipairs(class) do
            local data = scripted_ents.Get(v)
            if ( data ) then
                local ent = ents.Create(v)
                ent:Spawn()
                ent:Activate()
            end
        end
    else
        local data = scripted_ents.Get(class)
        if ( data ) then
            local ent = ents.Create(class)
            ent:Spawn()
            ent:Activate()
        end
    end

    if ( timer.Exists("ix_gWeatherCleanup") ) then
        timer.Remove("ix_gWeatherCleanup")
    end

    timer.Create("ix_gWeatherCleanup", duration, 1, function()
        hook.Run("WeatherEnd")
    end)

    return duration, weather
end

function PLUGIN:WeatherEnd()
    for _, v in ipairs(ents.FindByClass("gw_*")) do
        SafeRemoveEntity(v)
    end
end

function PLUGIN:Think()
    if ( CurTime() < self.next ) then return end

    if ( !ix.config.Get("weatherEnabled", true) ) then
        self.next = CurTime() + 1
        return
    end

    local duration = ix.config.Get("weatherInterval", 300)
    local weather = hook.Run("WeatherGetRandom")
    if ( weather ) then
        duration = duration + ix.config.Get("weatherDuration", 300)
    end

    self.next = CurTime() + duration

    hook.Run("WeatherStart", weather)
end