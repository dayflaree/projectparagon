
local PLUGIN = PLUGIN

PLUGIN.name = "Offline Character Bans"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows staff to ban characters which are not actively loaded on the server."

ix.lang.AddTable("english", {
	cmdCharBanOfflineDesc = "Ban a character not loaded onto the server.",
	cmdCharUnbanOfflineDesc = "Unban a character not loaded onto the server.",
	cmdCharUnbanOfflineNotBanned = "%s is not banned!",
	cmdCharBanOfflineOverloadedResult = "More than one character matches the parameters.",
	cmdCharBanOfflineNoResult = "No character matches the parameters.",
	cmdCharBanOfflineAlreadyBanned = "%s is already banned!",
	cmdCharBanOfflineSuccess = "%s has offline banned the character %s (%s).",
	cmdCharUnbanOfflineSuccess = "%s has offline unbanned the character %s (%s).",
	cmdCharBanOfflineCharacterLoaded = "%s is loaded on the server."
})

function PLUGIN:IsCharacterLoaded(id)
	return ix.char.loaded[tonumber(id)]
end

function PLUGIN:GetCharacter(client, character, steamID64, callback)

	local query = mysql:Select("ix_characters")
		query:Select("data")
		query:Select("id")

		query:Where("schema", Schema.folder)
		query:Where("name", character)
		query:Where("steamID", steamID64)

		query:Callback(function(result)
			if (result) then
				if (#result == 1) then
					callback(result[1].data, result[1].id)
				else
					client:NotifyLocalized("cmdCharBanOfflineOverloadedResult")
				end
			else
				client:NotifyLocalized("cmdCharBanOfflineNoResult")
			end
		end)
	query:Execute()

end

ix.command.Add("CharBanOffline", {
	description = "@cmdCharBanOfflineDesc",
	privilege = "Ban Character",
	adminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, steamID, character, minutes)
		local steamID64 = util.SteamIDTo64(steamID)
		PLUGIN:GetCharacter(client, character, steamID64, function(data, id)
			if (minutes) then
				minutes = os.time() + math.max(math.ceil(minutes * 60), 60)
			end

			if (id and PLUGIN:IsCharacterLoaded(id)) then
				client:NotifyLocalized("cmdCharBanOfflineCharacterLoaded", character)
				return
			end

			if (data and id) then
				local dataTable = util.JSONToTable(data)

				-- Allow if temporary ban is present in data.
				if (dataTable["banned"] and dataTable["banned"] == true) then
					client:NotifyLocalized("cmdCharBanOfflineAlreadyBanned", character)
				else
					dataTable["banned"] = minutes or true

					local query = mysql:Update("ix_characters")
						query:Update("data", util.TableToJSON(dataTable))
						query:Where("schema", Schema.folder)
						query:Where("id", id)
					query:Execute()

					for _, v in ipairs(player.GetAll()) do
						if (self:OnCheckAccess(v)) then
							v:NotifyLocalized("cmdCharBanOfflineSuccess", client:GetName(), character, steamID)
						end
					end

				end
			end
		end)
	end
})

ix.command.Add("CharUnbanOffline", {
	description = "@cmdCharUnbanOfflineDesc",
	privilege = "Ban Character",
	adminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.string
	},
	OnRun = function(self, client, steamID, character)
		local steamID64 = util.SteamIDTo64(steamID)		
		PLUGIN:GetCharacter(client, character, steamID64, function(data, id)
			if (id and PLUGIN:IsCharacterLoaded(id)) then
				client:NotifyLocalized("cmdCharBanOfflineCharacterLoaded", character)
				return
			end

			if (data and id) then
				local dataTable = util.JSONToTable(data)

				if (!dataTable["banned"]) then
					client:NotifyLocalized("cmdCharUnbanOfflineNotBanned", character)
				else
					dataTable["banned"] = nil

					local query = mysql:Update("ix_characters")
						query:Update("data", util.TableToJSON(dataTable))
						query:Where("schema", Schema.folder)
						query:Where("id", id)
					query:Execute()

					for _, v in ipairs(player.GetAll()) do
						if (self:OnCheckAccess(v)) then
							v:NotifyLocalized("cmdCharUnbanOfflineSuccess", client:GetName(), character, steamID)
						end
					end

				end
			end
		end)
	end
})
