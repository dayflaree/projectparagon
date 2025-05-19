-- Item Statistics

ITEM.name = "Small Medical Kit"
ITEM.description = "A small pack containing medical supplies."
ITEM.category = "Medical Items"

-- Item Configuration

ITEM.model = "models/mishka/models/firstaidkit.mdl"
ITEM.skin = 1

-- Item Inventory Size Configuration

ITEM.width = 1
ITEM.height = 1

-- Item Custom Configuration

ITEM.HealAmount = 40
ITEM.Volume = 50

-- Item Functions

ITEM.functions.Apply = {
	name = "Use",
	icon = "icon16/heart.png",
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