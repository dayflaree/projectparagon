local CHAR = ix.meta.character

function CHAR:IsClassD()
	return self:Team() == FACTION_CLASSD
end

function CHAR:IsMaintenance()
	return self:Team() == FACTION_MAINTENANCE
end

function CHAR:IsMedical()
	return self:Team() == FACTION_MEDICAL
end

function CHAR:IsScientific()
	return self:Team() == FACTION_SCIENTIFIC
end

function CHAR:IsSecurity()
	return self:Team() == FACTION_SECURITY
end

function CHAR:IsMTF()
	return self:Team() == FACTION_MTF
end

function CHAR:IsSiteDirector()
	return self:Team() == FACTION_SITEDIRECTOR
end

function CHAR:IsEthics()
	return self:Team() == FACTION_ETHICS
end

function CHAR:IsO5()
	return self:Team() == FACTION_O5
end

function CHAR:IsSCP()
	return self:Team() == FACTION_SCP
end

function CHAR:IsCI()
	return self:Team() == FACTION_CI
end
