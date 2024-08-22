local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedCharacter(ply, char)
    if ( GetGlobalInt("ixScheduleCurrent", 1) == 1 ) then
        if ( self.nextViolation and self.nextViolation > CurTime() ) then
            return
        end

        netstream.Start(nil, "EmitSound", "minerva/halflife2/dispatch/vo/city_curfewidle.wav", 500)
        Schema:SendDispatch("Citizen notice: Curfew violation detected in this sector. Protection Team, deploy to enforce curfew protocols. Code: apprehend, detain, interrogate! Maintain this sector!")
        
        self.nextViolation = CurTime() + 180
    end
end