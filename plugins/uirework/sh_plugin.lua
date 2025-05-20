local PLUGIN = PLUGIN

PLUGIN.name = "UI Rework"
PLUGIN.description = "Reworks parts of the UI from the Helix Framework to transform it into a SCP:CB Style."
PLUGIN.author = "Riggs"

if ( CLIENT ) then
    PLUGIN.font = "Courier New"
    PLUGIN.stored = PLUGIN.stored or {}

    function PLUGIN.RegisterFont(name, data)
        surface.CreateFont(name, data)

        PLUGIN.stored[name] = {
            name = name,
            data = data,
        }
    end

    function PLUGIN:LoadFonts()
        for i = 1, 15 do
            PLUGIN.RegisterFont("Font-Elements"..i * 5, {
                font = PLUGIN.font,
                size = i * 5,
                antialias = true,
            })

            PLUGIN.RegisterFont("Font-Elements-Italic"..i * 5, {
                font = PLUGIN.font,
                size = i * 5,
                antialias = true,
                italic = true,
            })

            PLUGIN.RegisterFont("Font-Elements-Bold"..i * 5, {
                font = PLUGIN.font,
                size = i * 5,
                antialias = true,
                weight = 1000,
            })
        end

        for i = 3, 20 do
            PLUGIN.RegisterFont("Font-Elements-ScreenScale"..i * 2, {
                font = PLUGIN.font,
                size = ScreenScale(i * 2),
                antialias = true,
            })

            PLUGIN.RegisterFont("Font-Elements-Italic-ScreenScale"..i * 2, {
                font = PLUGIN.font,
                size = ScreenScale(i * 2),
                antialias = true,
                italic = true,
            })

            PLUGIN.RegisterFont("Font-Elements-Bold-ScreenScale"..i * 2, {
                font = PLUGIN.font,
                size = ScreenScale(i * 2),
                antialias = true,
                weight = 1000,
            })
        end

        MsgC(Color(0, 255, 0), "Fonts Loaded.\n")
    end

    function PLUGIN:OnCharacterMenuCreated(panel)
        sound.PlayFile("sound/projectparagon/sfx/Music/loading_complete_music.wav", "noplay", function(channel, errorID, errorName)
            if (errorID) then
                MsgC(Color(255, 0, 0), "[Helix] Failed to play sound \""..errorName.."\".\n")
            else
                channel:SetVolume(1)
                channel:Play()
            end
        end)
    end

    concommand.Add("ix_loadfonts", function()
        MsgC(ix.config.Get("color"), "Loading Fonts...\n")

        hook.Run("LoadFonts")
    end)

    concommand.Add("ix_getfonts", function()
        MsgC(ix.config.Get("color"), "Stored Fonts:\n")

        for k, v in SortedPairs(PLUGIN.stored) do
            MsgC(color_white, k.."\n")
        end
    end)
end