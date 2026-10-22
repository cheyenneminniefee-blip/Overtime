// Keyboard Input Gathering
key_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
key_sprint = keyboard_check(vk_shift);
key_jump = keyboard_check_pressed(vk_space);
key_fire_down = keyboard_check(ord("S")) || keyboard_check(vk_down);
key_shoot = mouse_check_button_pressed(mb_left);
key_phase = keyboard_check_pressed(ord("E"));
key_freeze = keyboard_check_pressed(ord("Q"));
key_attack = mouse_check_button_pressed(mb_left);
key_dodge = keyboard_check_pressed(vk_control);
key_block = mouse_check_button(mb_right);          // Checks if holding right-click
key_block_pressed = mouse_check_button_pressed(mb_right); // Checks the initial click

// Decrement your dodge cooldown over time
if (dodge_cooldown > 0) {
    dodge_cooldown -= 1;
}

// Decrement wall jump lockout timer over time
if (wall_jump_timer > 0) {
    wall_jump_timer -= 1;
}

image_speed = 1;

// Basic Movement Calculations
var move = key_right - key_left;
if (state == player_states.idle_attack_1) || (state == player_states.idle_attack_2) || (state == player_states.idle_attack_3) || 
   (state == player_states.phase_slash)   || (state == player_states.dodge)         || (state == player_states.block) { // FIX: Stop movement input
    move = 0;
}

// Only apply standard walking/sprinting and gravity if NOT actively dodging or wall-hanging!
if (state != player_states.dodge) && (state != player_states.wall_hang) {
    if (wall_jump_timer <= 0 && hurt_timer <= 0) { // FIX: added hurt lockout
        if (key_sprint) && (move != 0) {
            hspd = move * sprint_spd;
        } else {
            hspd = move * walk_spd;
        }
    }
    vspd = vspd + grv; // Gravity always runs so your wall jump arcs naturally
}

// --- Ground Check And Jump Execution ---
if (place_meeting(x, y + 1, obj_solid)) && (key_jump) && 
   (state != player_states.idle_attack_1) && (state != player_states.idle_attack_2) && (state != player_states.idle_attack_3) && 
   (state != player_states.phase_slash) && (state != player_states.wall_hang) {
    
    vspd = jump_spd;
    draw_xscale = 0.7;
    draw_yscale = 1.3;
    
    // The player's state automatically switches to player_states.jump in the tracker below,
    // but their horizontal velocity (hspd) will remain high because key_sprint is still held!
}

// Time Freeze State Management
if (time_freeze_cd_timer > 0) {
    time_freeze_cd_timer -= 1;
}
if (global.time_frozen) {
    time_freeze_timer -= 1;
    if (time_freeze_timer <= 0) {
        global.time_frozen = false;
        time_freeze_cd_timer = 1800;
    }
} else if (key_freeze) && (time_freeze_cd_timer <= 0) {
    global.time_frozen = true;
    time_freeze_timer = 300;
}

// Overtime Core State Machine
if (hp <= 0) && (!is_overtime) {
    hp = 0;
    is_overtime = true;
    overtime_timer = 1800;
}
if (is_overtime) {
    overtime_timer -= 1;
    if (overtime_timer <= 0) {
        game_restart();
    }
}

// Wall Hang Latch Trigger
var grounded = place_meeting(x, y + 1, obj_solid);
if (!grounded) && (state == player_states.jump || state == player_states.air_attack) {
    if (wall_jump_timer <= 0) {
        var wall_latch = false;
        
        // Ensure the FULL height of the hitbox is touching the wall by checking top and bottom corners
        if (move == 1) { // Pushing Right
            var wall_top = position_meeting(bbox_right + 1, bbox_top, obj_solid);
            var wall_bottom = position_meeting(bbox_right + 1, bbox_bottom - 1, obj_solid); // -1 avoids floor tiles
            if (wall_top && wall_bottom && vspd >= 0) {
                wall_latch = true;
            }
        } else if (move == -1) { // Pushing Left
            var wall_top = position_meeting(bbox_left - 1, bbox_top, obj_solid);
            var wall_bottom = position_meeting(bbox_left - 1, bbox_bottom - 1, obj_solid);
            if (wall_top && wall_bottom && vspd >= 0) {
                wall_latch = true;
            }
        }
        
        if (wall_latch) {
            state = player_states.wall_hang;
            facing_dir = move; // Instantly sync facing direction to the wall side
            hspd = 0;
            vspd = 0;
        }
    }
}

// Horizontal Collision System
if (place_meeting(x + hspd, y, obj_solid)) {
    while (!place_meeting(x + sign(hspd), y, obj_solid)) {
        x = x + sign(hspd);
    }
    hspd = 0;
}
x = x + hspd;

// Vertical Collision System
if (place_meeting(x, y + vspd, obj_solid)) {
    while (!place_meeting(x, y + sign(vspd), obj_solid)) {
        y = y + sign(vspd);
    }
    vspd = 0;
}
y = y + vspd;

// --- Airborne And Landing State Tracker ---
if (state != player_states.idle_attack_1) && (state != player_states.idle_attack_2) && (state != player_states.idle_attack_3) && 
   (state != player_states.phase_slash)   && (state != player_states.walk_attack_1) && (state != player_states.walk_attack_2) &&
   (state != player_states.up_attack)     && (state != player_states.down_attack)   && (state != player_states.air_attack)    && 
   (state != player_states.dodge)         && (state != player_states.wall_hang)     && (state != player_states.block) { // FIX: Protect block state
       
    if (!grounded) {
        state = player_states.jump;
        was_airborne = true;
    } else {
        if (was_airborne) {
            draw_xscale = 1.4;
            draw_yscale = 0.6;
            was_airborne = false;
        }
        if (draw_yscale < 0.95) {
            state = player_states.jump;
        } else {
            if (hspd != 0) {
                if (key_sprint) {
                    state = player_states.sprint;
                } else {
                    state = player_states.walk;
                }
            } else {
                state = player_states.idle;
            }
        }
    }
}

// Combo And Cooldown Timer Decrement
if (attack_cooldown > 0) {
    attack_cooldown -= 1;
}
if (combo_timer > 0) {
    combo_timer -= 1;
}
if (buffer_lockout_timer > 0) {
    buffer_lockout_timer -= 1;
}
if (invuln_timer > 0) invuln_timer -= 1;
if (hurt_timer > 0)   hurt_timer -= 1;
if (parry_timer > 0)  parry_timer -= 1;
if (flash_timer > 0)  flash_timer -= 1;   // flash is now global (see note)

// Dodge State Activation Trigger
if (key_dodge) && (dodge_cooldown <= 0) {
    // Only allow dodging out of neutral physical states
    if (state == player_states.idle) || (state == player_states.walk) || (state == player_states.sprint) || (state == player_states.jump) {
        state = player_states.dodge;
        image_index = 0;
        
        // Start timers
        dodge_timer = dodge_duration;
        flash_timer = flash_duration;
        
        // Contextual Direction Snap: If holding a key, face that direction instantly
        var input_move = key_right - key_left;
        if (input_move != 0) {
            facing_dir = sign(input_move);
        }
    }
}

// Block State Activation Trigger
if (key_block_pressed) {
    // Only allow blocking out of neutral physical states
    if (state == player_states.idle) || (state == player_states.walk) || (state == player_states.sprint) || (state == player_states.jump) {
state = player_states.block;
image_index = 0;
parry_timer = parry_window;   // NEW — perfect parry window opens NOW
flash_timer = flash_duration; 
        
        // Optional Face Snap: Lock facing direction towards cursor or movement choice instantly
        var input_move = key_right - key_left;
        if (input_move != 0) facing_dir = sign(input_move);
    }
}

// Melee Attack State Trigger
if (key_attack) {
    
    // Active State Filter (Stops attacks from resetting themselves)
    if (state != player_states.idle_attack_1) && 
       (state != player_states.idle_attack_2) && 
       (state != player_states.idle_attack_3) && 
       (state != player_states.walk_attack_1) && 
       (state != player_states.walk_attack_2) && 
       (state != player_states.up_attack)     && 
       (state != player_states.down_attack)   && 
       (state != player_states.air_attack)    && 
       (state != player_states.phase_slash) {
        
        // 1. HIGH PRIORITY SPRINT CHECK: Phase Slash (Works Grounded AND Airborne!)
        // If holding sprint and moving horizontally, execute Phase Slash regardless of altitude
        if (hspd != 0 && key_sprint) {
            state = player_states.phase_slash;
            image_index = 0;
            attack_buffered = false; 
            buffer_lockout_timer = 2;
        } 
        // 2. HIGH PRIORITY AIR CHECKS (If not sprinting)
        else if (!grounded) {
            if (keyboard_check(ord("S")) || keyboard_check(vk_down)) {
                if (attack_cooldown <= 0) {
                    state = player_states.down_attack;
                    image_index = 0;
                    attack_buffered = false;
                    buffer_lockout_timer = 2;
                }
            }
            else if (keyboard_check(ord("W")) || keyboard_check(vk_up)) {
                if (attack_cooldown <= 0) {
                    state = player_states.up_attack;
                    image_index = 0;
                    attack_buffered = false;
                    buffer_lockout_timer = 2;
                }
            }
            else {
                if (attack_cooldown <= 0) {
                    state = player_states.air_attack;
                    image_index = 0;
                    attack_buffered = false;
                    buffer_lockout_timer = 2;
                }
            }
        }
        else {
            // 0. Grounded Up Attack
            if (keyboard_check(ord("W")) || keyboard_check(vk_up)) {
                if (attack_cooldown <= 0) {
                    state = player_states.up_attack;
                    image_index = 0;
                    attack_buffered = false;
                    buffer_lockout_timer = 2;
                }
            }
            // 1. Check if sprinting to execute Phase Slash
            else if (hspd != 0 && key_sprint && state!=player_states.wall_hang) {
                state = player_states.phase_slash;
                image_index = 0;
                attack_buffered = false; 
                buffer_lockout_timer = 2;
            } 
            // 2. Grounded Standing Combo
            else if (hspd == 0) {
                if (attack_cooldown <= 0) {
                    attack_buffered = false; 
                    if (combo_timer > 0) {
                        switch (combo_step) {
                            case 1: state = player_states.idle_attack_2; break;
                            case 2: state = player_states.idle_attack_3; break;
                            default: state = player_states.idle_attack_1; break;
                        }
                    } else {
                        state = player_states.idle_attack_1;
                    }
                    image_index = 0;
                    buffer_lockout_timer = 2; 
                }
            }
            // 3. Grounded Moving Combo
            else if (hspd != 0) && (state == player_states.walk) {
                if (attack_cooldown <= 0) {
                    attack_buffered = false;
                    if (combo_timer > 0) {
                        switch (walk_combo_step) {
                            case 1: state = player_states.walk_attack_2; break;
                            default: state = player_states.walk_attack_1; break;
                        }
                    } else {
                        state = player_states.walk_attack_1;
                    }
                    image_index = 0;
                    buffer_lockout_timer = 2;
                }
            }
        } // End Grounded Checks
    } // End Active State Filter
}

// Combo Step Reset Tracker
if (combo_timer <= 0) {
    combo_step = 0;
    walk_combo_step = 0; // FIX: Wipe out your moving counter when timer runs dry
}

// Direction And Scale Normalization
if (hspd != 0) {
    facing_dir = sign(hspd);
}
draw_xscale = lerp(draw_xscale, 1, 0.1);
draw_yscale = lerp(draw_yscale, 1, 0.1);

// Manually animate the legs frame counter based on current image speed
legs_image_index += (legs_image_speed * sprite_get_speed(legs_sprite_index) / game_get_speed(gamespeed_fps));

// Loop the legs animation cleanly so it doesn't break boundaries
if (legs_image_index >= sprite_get_number(legs_sprite_index)) {
    legs_image_index = 0;
}

// State Function Execution Selector
switch (state) {
    case player_states.idle:          scr_player_idle(); break;
    case player_states.walk:          scr_player_walk(); break;
    case player_states.jump:          scr_player_jump(); break;
    case player_states.idle_attack_1: scr_player_idle_attack_1(); break;
    case player_states.idle_attack_2: scr_player_idle_attack_2(); break;
    case player_states.idle_attack_3: scr_player_idle_attack_3(); break;
    case player_states.sprint:        scr_player_sprint(); break;
    case player_states.phase_slash:   scr_player_phase_slash(); break;
	case player_states.walk_attack_1: scr_player_walk_attack_1(); break;
	case player_states.walk_attack_2: scr_player_walk_attack_2(); break;
	case player_states.up_attack:     scr_player_up_attack(); break;
	case player_states.down_attack:   scr_player_down_attack(); break;
	case player_states.air_attack:    scr_player_air_attack(); break;
	case player_states.dodge:         scr_player_dodge(); break;
	case player_states.wall_hang:     scr_player_wall_hang(); break;
	case player_states.block:         scr_player_block(); break;
}