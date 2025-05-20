
local PLUGIN = PLUGIN
PLUGIN.name = "Perma Rank"
PLUGIN.author = "Taxin2012, riggs9162"
PLUGIN.description = "Makes rankes permanent."

ix.config.Add( "runRankHook", false, "Should plugin run PlayerJoinedRank hook?", nil, {
	category = "Perma Rank"
} )

if SERVER then
	function PLUGIN:PlayerJoinedRank( ply, rankInd, prevRank )
		local char = ply:GetCharacter()
		if char then
			char:SetData( "prank", rankInd )
		end
	end

	function PLUGIN:PlayerLoadedCharacter( ply, curChar, prevChar )
		local data = curChar:GetData( "prank" )
		if data then
			local rank = ix.rank.list[ data ]
			if rank then
				local oldRank = curChar:GetRank()

				if ply:Team() == rank.faction then
					timer.Simple( .3, function()
						curChar:SetRank( rank.index )

						if ix.config.Get( "runRankHook", false ) then
							hook.Run( "PlayerJoinedRank", ply, rank.index, oldRank )
						end
					end )
				end
			end
		end
	end
end
