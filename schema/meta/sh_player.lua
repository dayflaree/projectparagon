local PLAYER = FindMetaTable("Player")

-- move it if u must. couldnt find anywhere else i could put it.
function PLAYER:IsMTF()
	return self:Team() == FACTION_MTF
end
