function scr_player_air_attack() {
    sprite_index = spr_player_air_attack;
    image_speed = 1;
	normal_map=spr_player_walk_attack_1_nm;
    
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    // --- 1. LEGS & PHYSICS HANDLING ---
    if (!grounded) {
        // Airborne: standard dynamic jumping legs tracking
        legs_sprite_index = spr_player_legs_jump;
        legs_image_speed = 0;
        
        if (vspd < -1) {
            legs_image_index = 0; // Rising
        } else if (vspd > 1) {
            legs_image_index = 2; // Falling
        } else {
            legs_image_index = 1; // Apex
        }
    } else {
        // Grounded: Kill horizontal momentum to anchor the landing follow-through
        hspd = 0; 
        
        legs_sprite_index = spr_player_legs_idle;
        legs_image_index = 0;
        legs_image_speed = 0;
    }
    
    // --- 2. HITBOX HANDLING ---
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_air_attack_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    // --- 3. UNIFIED ANIMATION TERMINATION ---
    // The attack safely ignores landing interruptions and plays completely to the final frame
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        attack_cooldown = 8; // Brief recovery window
        
        // Contextually drop back to baseline states depending on final position
        if (!grounded) {
            state = player_states.jump;
        } else {
            // Check direct hardware keys to see if they immediately want to walk/run out of landing
            var move = key_right - key_left;
            if (move != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}