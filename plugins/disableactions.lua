PLUGIN.name = "Disable Actions"
PLUGIN.description = "Disables the ability for players to jump and crouch."
PLUGIN.author = "90"

if SERVER then
    function PLUGIN:PlayerButtonDown(client, button)
        if button == KEY_SPACE or button == KEY_LALT or button == KEY_RALT then
            return true
        end
    end
end

if CLIENT then
    function PLUGIN:PlayerBindPress(client, bind, pressed)
        if string.find(bind, "+jump") then
            return true
        end
    end
end