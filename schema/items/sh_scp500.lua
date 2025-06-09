-- Item Statistics

ITEM.name = "SCP-500"
ITEM.description = "A small red pill."
ITEM.category = "SCPs"

-- Item Configuration

ITEM.model = "models/cpthazama/scp/500.mdl"
ITEM.skin = 0

-- Item Inventory Size Configuration

ITEM.width = 1
ITEM.height = 1

-- Item Custom Configuration

ITEM.HealAmount = 99999
ITEM.Volume = 80

-- Item Functions

ITEM.functions.Apply = {
	name = "Use",
	OnCanRun = function(itemTable)
		local ply = itemTable.player

		if ( ply:IsValid() and ply:Health() < ply:GetMaxHealth() ) then
			return true
		else
			return false
		end
	end,
	OnRun = function(itemTable)
		local ply = itemTable.player
		ply:SetHealth(math.min(ply:Health() + itemTable.HealAmount, ply:GetMaxHealth()))
		ply:EmitSound("projectparagon/sfx/Interact/PickItem2.ogg", itemTable.Volume)
	end
}