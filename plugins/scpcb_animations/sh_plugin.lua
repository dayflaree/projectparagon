local PLUGIN = PLUGIN

PLUGIN.name = "SCP: Containment Breach Animations"
PLUGIN.author = "90, Riggs"
PLUGIN.description = "Animations for original SCP CB models that work for Helix."
PLUGIN.sequences = {
    [ACT_SIGNAL_GROUP] = "gesture_rally",
    [ACT_SIGNAL_HALT] = "gesture_hold"
}

function PLUGIN:PlayerShouldTaunt(ply, act)
    local sequence = self.sequences[act]
    if ( !sequence ) then return end

    ply:ForceSequence(sequence)
end

-- Class-D
ix.anim.classd = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

-- Maintenance
ix.anim.maintenance = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

-- Researcher
ix.anim.researcher = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

-- Guard
ix.anim.guard = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle_look"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    glide = ACT_IDLE,
}

-- NTF
ix.anim.ntf = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle_look"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    glide = ACT_IDLE,
}

-- Chaos
ix.anim.chaos = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle_look"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "throw_grenade"
    },
    glide = ACT_IDLE,
}

-- SCP-035
ix.anim.scp035 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

-- SCP-049
ix.anim.scp049 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"run", "run"},
        [ACT_MP_CROUCHWALK] = {"run", "run"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

-- SCP-096
ix.anim.scp096 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

ix.anim.scp106 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

-- SCP-427-1
ix.anim.scp427 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"standing_idle", "standing_idle"},
        [ACT_MP_CROUCH_IDLE] = {"crouch_idle", "crouch_idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"crouchwalk", "crouchwalk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "spitter_melee_01"
    },
    glide = ACT_IDLE,
}

-- SCP-682
ix.anim.scp682 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

-- SCP-939
ix.anim.scp939 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

-- SCP-966
ix.anim.scp966 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack_left"
    },
    glide = ACT_IDLE,
}

-- SCP-1048
ix.anim.scp1048 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
    },
    glide = ACT_IDLE,
}

-- SCP-1048-A
ix.anim.scp1048a = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

-- SCP-1499
ix.anim.scp1499 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack1"
    },
    glide = ACT_IDLE,
}

/*
[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
[ACT_MP_CROUCH_IDLE] = {ACT_IDLE, ACT_IDLE},
[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
[ACT_LAND] = {ACT_RESET, ACT_RESET}
