function scr_player_idle_attack_2() {
    sprite_index = spr_player_idle_attack_2;
    image_speed = 1;
    
	normal_map=spr_player_idle_attack_2_nm;
	
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_idle_attack_2_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }
    
    if (key_attack) && (buffer_lockout_timer <= 0) {
        attack_buffered = true;
    }
	
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
    
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        
        if (attack_buffered) {
            state = player_states.idle_attack_3; 
            image_index = 0;
            attack_buffered = false; 
            combo_step = 2; // Record that Hit 2 is historically complete
            buffer_lockout_timer = 2; 
        } else {
            attack_cooldown = 15;
            combo_timer = 25; 
            combo_step = 2; // Record that Hit 2 is historically complete
            state = player_states.idle;
        }
    }
}