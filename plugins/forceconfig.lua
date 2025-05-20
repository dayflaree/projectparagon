PLUGIN = PLUGIN or {} -- Initialize PLUGIN globally for server-side and metadata
PLUGIN.name = "Forced Configuration"
PLUGIN.author = "Day"
PLUGIN.description = "Adds server configuration options to forcefully enable smoothView and disableAnimations."

-- Add server-side configurations
ix.config.Add("forceSmoothView", false, "Force enable smooth view for all players.", nil, {
    category = "View Settings"
})

ix.config.Add("forceDisableAnimations", false, "Force disable animations for all players.", nil, {
    category = "View Settings"
})

if (SERVER) then
    function PLUGIN:OnConfigChanged(key, oldValue, newValue)
        if key == "forceSmoothView" or key == "forceDisableAnimations" then
            self:SyncSettings()
            print("[ViewConfig] Config changed: " .. key .. " = " .. tostring(newValue))
        end
    end
    
    function PLUGIN:SyncSettings()
        net.Start("ixViewSettingsSync")
            net.WriteBool(ix.config.Get("forceSmoothView", false))
            net.WriteBool(ix.config.Get("forceDisableAnimations", false))
        net.Broadcast()
        print("[ViewConfig] Synced settings to all clients")
    end
    
    function PLUGIN:InitializedPlugins()
        util.AddNetworkString("ixViewSettingsSync")
        self:SyncSettings()
    end
    
    function PLUGIN:PlayerInitialSpawn(client)
        timer.Simple(1, function()
            if IsValid(client) then
                net.Start("ixViewSettingsSync")
                    net.WriteBool(ix.config.Get("forceSmoothView", false))
                    net.WriteBool(ix.config.Get("forceDisableAnimations", false))
                net.Send(client)
                print("[ViewConfig] Synced settings to " .. client:Nick())
            end
        end)
    end
end

if (CLIENT) then
    -- Store forced settings
    local FORCED_SMOOTH_VIEW = false
    local FORCED_DISABLE_ANIMATIONS = false
    local nextCheck = 0 -- Local variable for Tick timing
    
    net.Receive("ixViewSettingsSync", function()
        FORCED_SMOOTH_VIEW = net.ReadBool()
        FORCED_DISABLE_ANIMATIONS = net.ReadBool()
        
        print("[ViewConfig] Received sync: smoothView=" .. tostring(FORCED_SMOOTH_VIEW) .. ", disableAnimations=" .. tostring(FORCED_DISABLE_ANIMATIONS))
        
        -- Apply immediately
        if FORCED_SMOOTH_VIEW then
            ix.option.Set("smoothView", true, true)
        end
        if FORCED_DISABLE_ANIMATIONS then
            ix.option.Set("disableAnimations", true, true)
        end
    end)
    
    -- Override Get
    local oldGetOption = ix.option.Get
    function ix.option.Get(key, default)
        local value = oldGetOption(key, default)
        if key == "smoothView" and FORCED_SMOOTH_VIEW then
            return true
        end
        if key == "disableAnimations" and FORCED_DISABLE_ANIMATIONS then
            return true
        end
        return value
    end
    
    -- Override Set
    local oldSetOption = ix.option.Set
    function ix.option.Set(key, value, bNoSave)
        if key == "smoothView" and FORCED_SMOOTH_VIEW and value == false then
            print("[ViewConfig] Blocked smoothView change to false")
            return oldSetOption(key, true, bNoSave)
        end
        if key == "disableAnimations" and FORCED_DISABLE_ANIMATIONS and value == false then
            print("[ViewConfig] Blocked disableAnimations change to false")
            return oldSetOption(key, true, bNoSave)
        end
        return oldSetOption(key, value, bNoSave)
    end
    
    -- Periodic enforcement
    local function Tick()
        if nextCheck > CurTime() then return end
        nextCheck = CurTime() + 1
        
        if FORCED_SMOOTH_VIEW and not ix.option.Get("smoothView", false) then
            ix.option.Set("smoothView", true, true)
            print("[ViewConfig] Enforced smoothView = true")
        end
        if FORCED_DISABLE_ANIMATIONS and not ix.option.Get("disableAnimations", false) then
            ix.option.Set("disableAnimations", true, true)
            print("[ViewConfig] Enforced disableAnimations = true")
        end
    end
    
    -- UI enforcement
    local function LoadFonts()
        timer.Simple(1, function()
            if not ViewConfig_originalPopulateOptions then
                ViewConfig_originalPopulateOptions = vgui.GetControlTable("ixSettings").PopulateOptions
                vgui.GetControlTable("ixSettings").PopulateOptions = function(panel, category)
                    ViewConfig_originalPopulateOptions(panel, category)
                    
                    print("[ViewConfig] Populating options for category: " .. tostring(category))
                    
                    for _, v in ipairs(panel:GetChildren()) do
                        if IsValid(v) and v.GetText then
                            local text = v:GetText():lower()
                            print("[ViewConfig] Found option: " .. text)
                            
                            if text:find("smooth view") and FORCED_SMOOTH_VIEW then
                                for _, checkbox in ipairs(v:GetChildren()) do
                                    if IsValid(checkbox) and checkbox:GetClassName() == "ixCheckBox" then
                                        checkbox:SetChecked(true)
                                        checkbox:SetEnabled(false)
                                        checkbox:SetHelixTooltip("This option is enforced by server settings")
                                        print("[ViewConfig] Disabled smooth view checkbox")
                                        break
                                    end
                                end
                            end
                            
                            if text:find("disable animations") and FORCED_DISABLE_ANIMATIONS then
                                for _, checkbox in ipairs(v:GetChildren()) do
                                    if IsValid(checkbox) and checkbox:GetClassName() == "ixCheckBox" then
                                        checkbox:SetChecked(true)
                                        checkbox:SetEnabled(false)
                                        checkbox:SetHelixTooltip("This option is enforced by server settings")
                                        print("[ViewConfig] Disabled animations checkbox")
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Tab menu enforcement
    local function OnTabMenuCreated(panel)
        if FORCED_SMOOTH_VIEW then
            ix.option.Set("smoothView", true, true)
        end
        if FORCED_DISABLE_ANIMATIONS then
            ix.option.Set("disableAnimations", true, true)
        end
    end
    
    -- Register hooks
    hook.Add("Tick", "ViewConfig_Tick", Tick)
    hook.Add("LoadFonts", "ViewConfig_LoadFonts", LoadFonts)
    hook.Add("OnTabMenuCreated", "ViewConfig_OnTabMenuCreated", OnTabMenuCreated)
end