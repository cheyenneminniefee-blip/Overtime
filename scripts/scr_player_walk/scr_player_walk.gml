function scr_player_walk() {
    sprite_index = spr_player_walk; // Torso asset fallback
    
    // Legs play the smooth walking cycle
    legs_sprite_index = spr_player_legs_walk;
    legs_image_speed = 1;
	
	normal_map=spr_player_walk_nm;
	leg_normal_map=spr_player_legs_walk_nm;
	
	image_index=legs_image_index;
}