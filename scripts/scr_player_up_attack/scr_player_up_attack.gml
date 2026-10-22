function scr_player_up_attack() {
    sprite_index = spr_player_up_attack;
    image_speed = 1;
	normal_map=spr_player_up_attack_nm;
    
    // --- 1. REAL-TIME MULTI-SCENARIO LEGS CONTROLLER ---
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    if (!grounded) {
        // Scenario A: Player is Airborne (Air Up-Attack)
        legs_sprite_index = spr_player_legs_jump;
        legs_image_speed = 0; // Freeze the legs to match jump logic
        
        // Match the leg frames to vertical velocity vectors
        if (vspd < -1) {
            legs_image_index = 0; // Rising
        } else if (vspd > 1) {
            legs_image_index = 2; // Falling
        } else {
            legs_image_index = 1; // Apex peak
        }
    } else {
        // Scenario B: Player is on the Ground (Grounded Up-Attack)
        if (hspd != 0) {
            if (key_sprint) {
                legs_sprite_index = spr_player_legs_sprint;
                legs_image_speed = 1.2;
            } else {
                legs_sprite_index = spr_player_legs_walk;
                legs_image_speed = 1;
            }
        } else {
            legs_sprite_index = spr_player_legs_idle;
            legs_image_speed = 1;
        }
    }
    
    // --- 2. HITBOX HANDLING ---
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_up_attack_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    // --- 3. ANIMATION TERMINATION ---
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        attack_cooldown = 12; // Recovery window
        
        // Return contextually to whatever baseline state matches current environment
        if (!grounded) {
            state = player_states.jump;
        } else {
            if (hspd != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}