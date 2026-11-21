function scr_player_dodge() {
    sprite_index = spr_player_dodge;
    image_speed = 0; // Freeze processing (safe for 1-frame graphics)
	normal_map=spr_player_dodge_nm;
    
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    // --- 1. PHYSICS & TIMERS ---
    hspd = facing_dir * dodge_spd;   // per-frame velocity; integration scales with dt in Step
    var _dt = scr_dt();

    // Air dodge: a straight horizontal line — vertical momentum cancelled at
    // start, gravity suspended for the whole burst, fall resumes from vspd 0.
    // Ground dodge: gravity resumes on the first unsupported frame — the burst
    // continues as a dash and a normal fall, never a hover (PRD 5.5).
    if (dodge_was_air || grounded) {
        vspd = 0;
    } else {
        vspd = vspd + grv * _dt;
    }

    // After-images: 3 ghosts over the 12-frame burst (PRD 5.5) — at elapsed
    // 0 (seeded by the trigger), 4, and 8. Delta-time safe: a spawn
    // accumulator fires once per 4 nominal frames and carries the remainder
    // across dropped/partial steps.
    dodge_ghost_tick += scr_dt();
    if (dodge_ghost_tick >= 4) {
        dodge_ghost_tick -= 4;
        if (dodge_timer > 0) {   // the last interval ends exactly at burst end
            array_push(dodge_ghosts, {
                spr: sprite_index,
                ind: image_index,
                x: x,
                y: y,
                xs: facing_dir * draw_xscale,
                ys: draw_yscale,
                t: 0
            });
        }
    }
    
    if (flash_timer > 0)  flash_timer -= scr_dt();
    if (dodge_timer > 0)  dodge_timer -= scr_dt();
    
    // --- 2. TERMINATION ---
    if (dodge_timer <= 0) {
        // 0.5 s cooldown anchored to dodge end (PRD 5.5)
        dodge_cooldown = dodge_cooldown_max;
        
        var move = key_right - key_left;
        
        if (!grounded) {
            // Exit clamp: the burst speed exists only inside the burst (PRD 5.5)
            hspd = clamp(hspd, -sprint_spd, sprint_spd);
            state = player_states.jump;
        }
        else if (key_sprint) && (move != 0) && (stamina >= 15) {
            // Holding through the burst continues into sprint — only with 15+
            // stamina remaining; fewer than 15 leaves a walk (PRD 5.5, 5.6)
            hspd = move * sprint_spd;
            state = player_states.sprint;
        }
        else {
            // Releasing during the burst leaves a plain dodge
            hspd = move * walk_spd;
            state = (move != 0) ? player_states.walk : player_states.idle;
        }
    }
}
