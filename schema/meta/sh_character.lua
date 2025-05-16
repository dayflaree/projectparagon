local CHAR = ix.meta.character

function CHAR:IsClassD()
	return self:GetFaction() == FACTION_CLASSD
end

function CHAR:IsMaintenance()
	return self:GetFaction() == FACTION_MAINTENANCE
end

function CHAR:IsMedical()
	return self:GetFaction() == FACTION_MEDICAL
end

function CHAR:IsScientific()
	return self:GetFaction() == FACTION_SCIENTIFIC
end

function CHAR:IsSecurity()
	return self:GetFaction() == FACTION_SECURITY
end

function CHAR:IsMTF()
	return self:GetFaction() == FACTION_MTF
end

function CHAR:IsSiteDirector()
	return self:GetFaction() == FACTION_SITEDIRECTOR
end

function CHAR:IsSCP()
	return self:GetFaction() == FACTION_SCP
end

function CHAR:IsCI()
	return self:GetFaction() == FACTION_CI
end
