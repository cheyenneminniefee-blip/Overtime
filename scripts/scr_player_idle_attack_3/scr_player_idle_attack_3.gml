function scr_player_idle_attack_3() {
    sprite_index = spr_player_idle_attack_3;
    image_speed = 1;
	normal_map=spr_player_idle_attack_3_nm;
    
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_idle_attack_3_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
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
        
        attack_cooldown = 25; 
        combo_timer = 0;      
        combo_step = 0;       // Reset combo step completely back to neutral
        state = player_states.idle;
    }
}