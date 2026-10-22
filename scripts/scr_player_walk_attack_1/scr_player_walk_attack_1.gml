function scr_player_walk_attack_1() {
    sprite_index = spr_player_walk_attack_1;
    image_speed = 1;
	
	normal_map=spr_player_walk_attack_1_nm;
    
    // Legs Rendering Loop Pass-Through
    if (hspd != 0) {
        legs_sprite_index = spr_player_legs_walk;
        legs_image_speed = 1;
    } else {
        legs_sprite_index = spr_player_legs_idle;
        legs_image_speed = 1;
    }
    
    // Create Hitbox Instance
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_walk_attack_1_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    // Handle Input Buffering
    if (key_attack) && (buffer_lockout_timer <= 0) {
        attack_buffered = true;
    }
    
    // Termination Verification
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        walk_combo_step = 1; // Flag historical moving completion status
        
        if (attack_buffered) {
            state = player_states.walk_attack_2; // Smooth chain forward
            image_index = 0;
            attack_buffered = false;
            buffer_lockout_timer = 2;
        } else {
            attack_cooldown = 1;
            combo_timer = 45; // Open timing window for consecutive slashes
            
            if (hspd != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}