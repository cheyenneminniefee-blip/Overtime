function scr_player_wall_hang() {
    sprite_index = spr_player_wall_hang;
    image_speed = 1;
	
	normal_map=spr_player_wall_hang_nm;
    
    // Freeze movement vectors while hanging
    hspd = 0;
    vspd = 0;
    
var move = key_right - key_left;
    var wall_on_left = place_meeting(x - 1, y, obj_solid);
    var wall_on_right = place_meeting(x + 1, y, obj_solid);
    
    if (wall_on_left)  facing_dir = -1;
    if (wall_on_right) facing_dir = 1;
    
    // 2. LEDGE DETECTION POSITION CHECK
    var side_x = (facing_dir == 1) ? bbox_right + 1 : bbox_left - 1;
    var is_at_ledge = !position_meeting(side_x, bbox_top - 10, obj_solid);
    
    // 3. CONTEXTUAL JUMP MECHANICAL INPUT
    if (key_jump) {
        if (is_at_ledge) {
            vspd = -7.5;             
            hspd = facing_dir * 3.5;  
            wall_jump_timer = 14; 
            
            draw_xscale = 1.2;
            draw_yscale = 0.8;
            
            state = player_states.jump;
            exit;
        } else {
            facing_dir = -facing_dir; 
            hspd = facing_dir * 5.5;  
            vspd = -7;                
            wall_jump_timer = 12;     
            
            draw_xscale = 0.7;
            draw_yscale = 1.3;
            
            state = player_states.jump;
            exit;
        }
    }
    
    // 4. CONTINUOUS HOLD FILTER & MANUAL DETACHMENT
    // FIX: Only detach if actively pushing AWAY from the wall (move == -facing_dir), 
    // rather than just letting go of the stick (move == 0).
    if (key_fire_down) {
        hspd = -facing_dir * 2; // Shove away slightly harder to clear sub-pixels
        wall_jump_timer = 15;   // Give a healthy frame buffer so you can't instantly re-latch
        state = player_states.jump;
        exit;
    }
    
    // 5. GROUND CONTACT CHECK
    if (place_meeting(x, y + 1, obj_solid)) {
        state = player_states.idle;
    }
}