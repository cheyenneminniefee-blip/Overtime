function scr_player_down_attack() {
    sprite_index = spr_player_down_attack;
    image_speed = 1;
	
	normal_map=spr_player_down_attack_nm;
    
    var grounded = place_meeting(x, y + 1, obj_solid);
    
    // --- 1. LEGS & PHYSICS HANDLING ---
    if (!grounded) {
        // Airborne: standard falling legs orientation
        legs_sprite_index = spr_player_legs_jump;
        legs_image_index = 2; 
        legs_image_speed = 0;
    } else {
        // Grounded: Kill horizontal momentum so they slide-lock into the landing impact
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
        attack_hitbox.sprite_index = spr_player_down_attack_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    // --- 3. UNIFIED ANIMATION TERMINATION ---
    // The attack now ONLY ends when the animation frames have completely finished cycling
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        attack_cooldown = 10; // Recovery frames
        
        // Contextually exit back to baseline states based on where the player ended up
        if (!grounded) {
            state = player_states.jump;
        } else {
            // Check keyboard inputs directly since we forced hspd to 0 above
            var move = key_right - key_left;
            if (move != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}