function scr_player_walk_attack_2() {
    sprite_index = spr_player_walk_attack_2;
    image_speed = 1;
	normal_map=spr_player_walk_attack_2_nm;
    
    // Keep legs cycling smoothly under your torso attack art
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
        attack_hitbox.sprite_index = spr_player_walk_attack_2_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    // Termination Verification (Finisher)
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        // Reset moving variables completely 
        attack_cooldown = 20; 
        combo_timer = 0;      
        walk_combo_step = 0; 
        
        // Return to standard movement loops
        if (hspd != 0) {
            state = (key_sprint) ? player_states.sprint : player_states.walk;
        } else {
            state = player_states.idle;
        }
    }
}