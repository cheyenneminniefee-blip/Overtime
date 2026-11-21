function scr_player_jump() {
    sprite_index = spr_player_jump;
	
	legs_sprite_index = spr_player_legs_jump;
	
	normal_map=spr_player_jump_nm;
	leg_normal_map=spr_player_legs_jump_nm;
    
    if (!place_meeting(x, y + 1, obj_solid)) {
		image_speed = 0;
        if (vspd < -1) {
            image_index = 0;
			legs_image_index = 0;
        } else if (vspd > 1) {
            image_index = 2;
			legs_image_index = 2;
        } else {
            image_index = 1;
			legs_image_index = 1;
        }
    } else {
		image_speed=10;
        image_index = 3;
		legs_image_index = 3;
    }
}