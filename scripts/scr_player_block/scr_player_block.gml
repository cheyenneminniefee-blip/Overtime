function scr_player_block() {
    sprite_index = spr_player_block;
    image_speed = 0; // Freeze frame execution since it's a single frame asset
	
	normal_map=spr_player_block_nm;
    
    // Lock position values rigidly in space
    hspd = 0;
    
    // Handle the white flash timer inherited from dodge logic
    if (flash_timer > 0) {
        flash_timer -= 1;
    }
    
    // TERMINATION: Release right-click to drop the block state safely
    if (!key_block) {
        var grounded = place_meeting(x, y + 1, obj_solid);
		flash_timer=0;
        
        if (!grounded) {
            state = player_states.jump;
        } else {
            var move = key_right - key_left;
            if (move != 0) {
                state = (key_sprint) ? player_states.sprint : player_states.walk;
            } else {
                state = player_states.idle;
            }
        }
    }
}