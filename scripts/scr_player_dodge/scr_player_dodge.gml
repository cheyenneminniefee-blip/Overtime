function scr_player_dodge() {
    sprite_index = spr_player_dodge;
    image_speed = 0; // Freeze processing (safe for 1-frame graphics)
	normal_map=spr_player_dodge_nm;
    
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    // --- 1. PHYSICS & TIMERS ---
    hspd = facing_dir * dodge_spd;
    vspd = 0; // Suspend gravity for a snappy, uniform horizontal glide
    
    if (flash_timer > 0)  flash_timer -= 1;
    if (dodge_timer > 0)  dodge_timer -= 1;
    
    // --- 2. TERMINATION ---
    if (dodge_timer <= 0) {
        hspd = 0;
        dodge_cooldown = 20; // Brief cooldown frame delay before dodging again
        
        if (!grounded) {
            state = player_states.jump;
        } else {
            var move = key_right - key_left;
            if (move != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}