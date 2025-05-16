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
	name = "Heal yourself",
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

ITEM.functions.ApplyTarget = {
	name = "Heal target",
	icon = "icon16/heart_add.png",
	OnCanRun = function(itemTable)
		local ply = itemTable.player
		local data = {}
			data.start = ply:GetShootPos()
			data.endpos = data.start + ply:GetAimVector() * 96
			data.filter = ply
		local target = util.TraceLine(data).Entity

		if ( target:IsValid() and target:IsPlayer() and ( target:Health() < target:GetMaxHealth() ) ) then
			return true
		else
			return false
		end
	end,
	OnRun = function(itemTable)
		local ply = itemTable.player
		local data = {}
			data.start = ply:GetShootPos()
			data.endpos = data.start + ply:GetAimVector() * 96
			data.filter = ply
		local target = util.TraceLine(data).Entity

		if IsValid(target) and target:IsPlayer() then
			if target:GetCharacter() then
				ply:SetHealth(math.min(ply:Health() + itemTable.HealAmount, ply:GetMaxHealth()))
				ply:EmitSound("scprp/sfx/interact/pickitem2.mp3", itemTable.Volume)
				target:EmitSound("scprp/sfx/interact/pickitem2.mp3", itemTable.Volume)
				target:SetHealth(math.min(target:Health() + itemTable.HealAmount, target:GetMaxHealth()))

				ply:Notify("You applied a "..itemTable.name.." on yourself and you have gained health.")
				target:Notify(ply:Nick().." applied a "..itemTable.name.." on you and you have gained health.")
				
				return true
			end
		end

		return false
	end
}