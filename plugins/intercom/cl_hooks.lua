local PLUGIN = PLUGIN

-- This file is mostly for UI elements or client-side sounds not tied to the entity directly.
-- For instance, if you wanted a global "BROADCASTING" message on everyone's screen.

-- Example: Display a global message when someone is broadcasting
-- This is a bit more involved as it requires networking the broadcaster's name or status.
-- For simplicity, the current setup relies on sounds and entity visuals.

-- If you wanted a screen overlay:
-- local isBroadcastingActive = false
-- local broadcasterName = ""

-- net.Receive("IntercomBroadcastState", function()
--     isBroadcastingActive = net.ReadBool()
--     if (isBroadcastingActive) then
--         broadcasterName = net.ReadString()
--     else
--         broadcasterName = ""
--     end
-- end)

-- hook.Add("HUDPaint", "IntercomBroadcastHUD", function()
--     if (isBroadcastingActive and LocalPlayer():Alive()) then
--         local w, h = ScrW(), ScrH()
--         draw.RoundedBox(8, w * 0.3, h * 0.05, w * 0.4, 50, Color(20, 20, 20, 200))
--         draw.SimpleText("LIVE BROADCAST: " .. broadcasterName, "DermaLarge", w * 0.5, h * 0.05 + 25, Color(255, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     end
-- end)

-- To make the above HUD work, you'd need to send net messages from sv_hooks.lua:
-- When broadcast starts:
-- net.Start("IntercomBroadcastState")
-- net.WriteBool(true)
-- net.WriteString(ply:Name()) -- Or char name: ply:GetCharacter():GetName()
-- net.Broadcast()

-- When broadcast ends:
-- net.Start("IntercomBroadcastState")
-- net.WriteBool(false)
-- net.Broadcast()