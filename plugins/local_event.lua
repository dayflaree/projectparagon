
local PLUGIN = PLUGIN

PLUGIN.name = "Better Local Event"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds a local event command for events in a specified radius."

ix.lang.AddTable("english", {
    cmdLocalEvent = "Make something perform an action that can be seen at a specified radius."
})

if (CLIENT) then
    function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
        if (bDrawingDepth or bDrawingSkybox) then
            return
        end

        if (ix.chat.currentCommand == "localevent") then
            render.SetColorMaterial()
            render.DrawSphere(LocalPlayer():GetPos(), -(tonumber(ix.chat.currentArguments[2]) or 500), 30, 30, Color(255, 150, 0, 100))
        end
    end
end

do
    local COMMAND = {}
    COMMAND.description = "@cmdLocalEvent"
    COMMAND.arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional)}
    COMMAND.superAdminOnly = true

    function COMMAND:OnRun(ply, event, radius)
        ix.chat.Send(ply, "localevent", event, nil, nil, {range = radius})
    end

    ix.command.Add("LocalEvent", COMMAND)
end

do
    local CLASS = {}
    CLASS.color = Color(255, 150, 0)
    CLASS.superAdminOnly = true
    CLASS.indicator = "chatPerforming"

    function CLASS:CanHear(speaker, listener, data)
        return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range ^ 2 or 250000)
    end

    function CLASS:OnChatAdd(speaker, text)
        chat.AddText(self.color, text)
    end

    ix.chat.Register("localevent", CLASS)
end
