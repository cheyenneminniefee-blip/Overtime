function scr_player_idle() {
    // Upper body defaults to idle if not attacking
    sprite_index = spr_player_idle; 
    
	image_index=legs_image_index;
	
    // Legs switch to idle
    legs_sprite_index = spr_player_legs_idle;
    legs_image_speed = 1;
	
	normal_map=spr_player_idle_nm;
	leg_normal_map=spr_player_legs_idle_nm;
}