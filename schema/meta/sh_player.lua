local PLAYER = FindMetaTable("Player")

function PLAYER:IsClassD()
	return self:Team() == FACTION_CLASSD
end

function PLAYER:IsMaintenance()
	return self:Team() == FACTION_MAINTENANCE
end

function PLAYER:IsMedical()
	return self:Team() == FACTION_MEDICAL
end

function PLAYER:IsScientific()
	return self:Team() == FACTION_SCIENTIFIC
end

function PLAYER:IsSecurity()
	return self:Team() == FACTION_SECURITY
end

function PLAYER:IsMTF()
	return self:Team() == FACTION_MTF
end

function PLAYER:IsSiteDirector()
	return self:Team() == FACTION_SITEDIRECTOR
end

function PLAYER:IsCI()
	return self:Team() == FACTION_CI
end

function PLAYER:IsSCP()
	return self:Team() == FACTION_SCP
end
