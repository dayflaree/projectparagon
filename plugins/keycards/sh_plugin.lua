local PLUGIN = PLUGIN

PLUGIN.name = "Keycards"
PLUGIN.description = ""
PLUGIN.author = "Reece™"

ix.keycards = ix.keycards or {}

local PLAYER = FindMetaTable("Player")

function PLAYER:GetAccessLevel()
    local char = self:GetCharacter()
    local inventory = char:GetInventory()

	if ( inventory:HasItem("key6") ) then
		return 6
	elseif ( inventory:HasItem("key5") ) then
		return 5
	elseif ( inventory:HasItem("key4") ) then
		return 4
	elseif ( inventory:HasItem("key3") ) then
		return 3
	elseif ( inventory:HasItem("key2") ) then
		return 2
	elseif ( inventory:HasItem("key1") ) then
		return 1
	else
		return 0
	end
end

ix.util.Include("sv_plugin.lua")

ix.command.Add("AddKeycardLevel", {
    description = "",
    adminOnly = true,
    arguments = {
        ix.type.number,
    },
    OnRun = function(self, ply, level)
        ix.keycards.SetLevel(ply:GetEyeTraceNoCursor().Entity, level)
    end,
})