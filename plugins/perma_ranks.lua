
local PLUGIN = PLUGIN
PLUGIN.name = "Perma Rank"
PLUGIN.author = "Taxin2012, Riggs"
PLUGIN.description = "Makes ranks permanent."
PLUGIN.license = [[Copyright 2019 Taxin2012

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.]]

ix.config.Add( "runClassHook", false, "Should plugin run PlayerJoinedClass hook?", nil, {
    category = "Server"
} )

if SERVER then
    function PLUGIN:PlayerJoinedClass( ply, classInd, prevClass )
        local char = ply:GetCharacter()
        if char then
            char:SetData( "prank", classInd )
        end
    end

    function PLUGIN:PlayerLoadedCharacter( ply, curChar, prevChar )
        local data = curChar:GetData( "prank" )
        if data then
            local rank = ix.rank.list[ data ]
            if rank then
                local oldClass = curChar:GetRank()

                if ply:Team() == rank.faction then
                    timer.Simple( .3, function()
                        curChar:SetClass( rank.index )

                        if ix.config.Get( "runClassHook", false ) then
                            hook.Run( "PlayerJoinedRank", ply, rank.index, oldClass )
                        end
                    end )
                end
            end
        end
    end
end
