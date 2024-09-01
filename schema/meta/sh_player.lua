local PLAYER = FindMetaTable("Player")

-- move it if u must. couldnt find anywhere else i could put it.
function PLAYER:IsE11()
	return self:Team() == FACTION_E11
end