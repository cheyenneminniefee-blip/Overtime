function scr_player_dodge() {
    sprite_index = spr_player_dodge;
    image_speed = 0; // Freeze processing (safe for 1-frame graphics)
	normal_map=spr_player_dodge_nm;
    
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    // --- 1. PHYSICS & TIMERS ---
    hspd = facing_dir * dodge_spd;

    // Air dodge: a straight horizontal line — vertical momentum cancelled at
    // start, gravity suspended for the whole burst, fall resumes from vspd 0.
    // Ground dodge: gravity resumes on the first unsupported frame — the burst
    // continues as a dash and a normal fall, never a hover (PRD 5.5).
    if (dodge_was_air || grounded) {
        vspd = 0;
    } else {
        vspd = vspd + grv;
    }

    // After-images: 3 ghosts at 2 PRD-frame (4 frame) intervals (PRD 5.5)
    var _elapsed = dodge_duration - dodge_timer;
    if (_elapsed == 0) || (_elapsed == 4) || (_elapsed == 8) {
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
    
    if (flash_timer > 0)  flash_timer -= 1;
    if (dodge_timer > 0)  dodge_timer -= 1;
    
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
        else if (key_sprint) && (move != 0) {
            // Holding through the burst continues into sprint (PRD 5.5)
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
