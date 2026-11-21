function scr_player_sprint() {
    sprite_index = spr_player_sprint;
    image_speed = 1; // Slightly faster animation speed to match high velocity
    
	legs_sprite_index = spr_player_legs_sprint;
    legs_image_speed = 1.2; // Match sprinting speed rhythm
	
	normal_map=spr_player_sprint_nm;
	leg_normal_map=spr_player_legs_sprint_nm;
	
    // Calculate movement using sprint speed
    var move = key_right - key_left;
    hspd = move * sprint_spd;
    
    // State Transitions out of Sprint
    if (move == 0) {
        state = player_states.idle;
    } else if (!key_sprint) {
        state = player_states.walk;
    }
}