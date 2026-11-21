// Keyboard Input Gathering
key_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
key_sprint = keyboard_check(vk_shift);
key_jump = keyboard_check_pressed(vk_space);
key_fire_down = keyboard_check(ord("S")) || keyboard_check(vk_down);
key_shoot = mouse_check_button_pressed(mb_left);
key_phase = keyboard_check_pressed(ord("E"));
key_freeze = keyboard_check_pressed(ord("Q"));
key_grenade = keyboard_check_pressed(ord("G"));   // PRD 4.3: Photon Grenade
key_attack = mouse_check_button_pressed(mb_left);
key_attack_held = mouse_check_button(mb_left);   // PRD 5.8 tap/hold contract: pressed vs still-down
key_dodge = keyboard_check_pressed(vk_shift);   // PRD 5.5: the Shift press fires the dodge; holding continues into sprint
key_block = mouse_check_button(mb_right);          // Checks if holding right-click
key_block_pressed = mouse_check_button_pressed(mb_right); // Checks the initial click

// --- DEBUG HEAVY WEAPON SWAP (PRD 5.8: real swaps happen at the L6 armory
// pedestals / checkpoint swap menus — these keybinds are for testing only,
// delete them when the swap menu lands) ---
//   1 = WEAPON.NONE (Hard Light Sword only, pre-armory behavior)
//   2 = WEAPON.GREATSWORD
//   3 = WEAPON.SPEAR
// NOTE: when the mace logic lands, add 4 = WEAPON.MACE here.

// Delta-time scale (see scr_dt): 1.0 at the nominal 60 steps/s; > 1 when
// steps are dropped. Every velocity integration, timer, and regen below
// scales by it so gameplay advances in real seconds at any step rate.
var _dt = scr_dt();

// Decrement your dodge cooldown over time
if (dodge_cooldown > 0) {
    dodge_cooldown -= _dt;
}

// Decrement wall jump lockout timer over time
if (wall_jump_timer > 0) {
    wall_jump_timer -= _dt;
}

image_speed = _dt;

// Basic Movement Calculations
var move = key_right - key_left;
if (state == player_states.idle_attack_1) || (state == player_states.idle_attack_2) || (state == player_states.idle_attack_3) || 
   (state == player_states.phase_slash)   || (state == player_states.dodge)         || (state == player_states.block) ||
   (state == player_states.heavy_attack) {   // PRD 5.8: locked in — rooted, every movement input ignored
    move = 0;
}

// --- PRD 5.8 tap/hold contract: track the attack button's hold length ---
// A press resets the counter; holding past HEAVY_HOLD_THRESHOLD commits; a
// release invalidates it until the next press.
if (key_attack) {
    heavy_hold_timer = 0;
} else if (!key_attack_held) {
    heavy_hold_timer = -1;
} else if (heavy_hold_timer >= 0) {
    heavy_hold_timer += _dt;
}

// Debug heavy weapon swap (see keybind notes above);
// 1 = none, 2 = greatsword, 3 = spear // TODO: 4 = mace when the mace lands
if (keyboard_check_pressed(ord("1"))) heavy_weapon = WEAPON.NONE;
else if (keyboard_check_pressed(ord("2"))) heavy_weapon = WEAPON.GREATSWORD;
else if (keyboard_check_pressed(ord("3"))) heavy_weapon = WEAPON.SPEAR;

// Sprint availability (PRD 5.6): engaging needs 15 stamina (30 after emptying —
// anti-flutter); an ongoing sprint sustains until stamina reaches 0.
var _sprint_min = (sprint_needs_reengage) ? 30 : 15;
var _sprint_ok = (state == player_states.sprint) ? (stamina > 0) : (stamina >= _sprint_min);

// Only apply standard walking/sprinting and gravity if NOT actively dodging or wall-hanging!
if (state != player_states.dodge) && (state != player_states.wall_hang) {
    if (wall_jump_timer <= 0 && hurt_timer <= 0) { // FIX: added hurt lockout
        if (key_sprint) && (move != 0) && (_sprint_ok) {
            hspd = move * sprint_spd;
        } else {
            hspd = move * walk_spd;
        }
    }
    vspd = vspd + grv * _dt; // Gravity always runs so your wall jump arcs naturally
}

// --- Ground Check And Jump Execution ---
if (place_meeting(x, y + 1, obj_solid)) && (key_jump) && 
   (state != player_states.idle_attack_1) && (state != player_states.idle_attack_2) && (state != player_states.idle_attack_3) && 
   (state != player_states.phase_slash) && (state != player_states.wall_hang) && (state != player_states.dodge) &&
   (state != player_states.heavy_attack) {   // PRD 5.8: locked in — inputs ignored
    
    vspd = jump_spd;
    hspd = clamp(hspd, -sprint_spd, sprint_spd);   // Takeoff clamp: a jump out of a burst is a sprint-jump, never a rocket (PRD 5.5)
    draw_xscale = 0.7;
    draw_yscale = 1.3;
    
    // The player's state automatically switches to player_states.jump in the tracker below,
    // but their horizontal velocity (hspd) will remain high because key_sprint is still held!
}

// Time Freeze: the time-domain manager owns duration, cooldown, and state
if (key_freeze) scr_time_freeze_request();

// Photon Grenade: instant throw, a free action from any state (PRD 5.7)
if (key_grenade) scr_player_throw_grenade();

// Overtime Core State Machine
if (hp <= 0) && (!is_overtime) {
    hp = 0;
    is_overtime = true;
    overtime_timer = 1800;
}
if (is_overtime) {
    overtime_timer -= _dt;
    if (overtime_timer <= 0) {
        // Timer expiry is True Death (PRD 5.1) — the Afterlife arrives later
        scr_player_true_death();
        exit;
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

// Horizontal Collision System (per-frame displacement scales with delta time)
var _dx = hspd * _dt;
if (_dx != 0) {
    if (place_meeting(x + _dx, y, obj_solid)) {
        while (!place_meeting(x + sign(_dx), y, obj_solid)) {
            x = x + sign(_dx);
        }
        hspd = 0;
    }
    x = x + _dx;
}

// Vertical Collision System
var _dy = vspd * _dt;
if (_dy != 0) {
    if (place_meeting(x, y + _dy, obj_solid)) {
        while (!place_meeting(x, y + sign(_dy), obj_solid)) {
            y = y + sign(_dy);
        }
        vspd = 0;
    }
    y = y + _dy;
}

// Landing refreshes the air dodge (PRD 5.5)
if (place_meeting(x, y + 1, obj_solid)) {
    dodge_air_used = false;
}

// --- Airborne And Landing State Tracker ---
if (state != player_states.idle_attack_1) && (state != player_states.idle_attack_2) && (state != player_states.idle_attack_3) && 
   (state != player_states.phase_slash)   && (state != player_states.walk_attack_1) && (state != player_states.walk_attack_2) &&
   (state != player_states.up_attack)     && (state != player_states.down_attack)   && (state != player_states.air_attack)    && 
   (state != player_states.dodge)         && (state != player_states.wall_hang)     && (state != player_states.block) &&
   (state != player_states.heavy_attack) { // PRD 5.8: heavy is ground-only — the landing tracker must not yank it into jump
       
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
                if (key_sprint) && (_sprint_ok) {
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
    attack_cooldown -= _dt;
}
if (combo_timer > 0) {
    combo_timer -= _dt;
}
if (buffer_lockout_timer > 0) {
    buffer_lockout_timer -= _dt;
}
if (invuln_timer > 0) invuln_timer -= _dt;
if (hurt_timer > 0)   hurt_timer -= _dt;
if (parry_timer > 0)  parry_timer -= _dt;
if (freeze_fizzle_timer > 0) freeze_fizzle_timer -= _dt;
if (flash_timer > 0)  flash_timer -= _dt;   // flash is now global (see note)
if (phase_slash_cooldown > 0) phase_slash_cooldown -= _dt;

// --- Resource upkeep (PRD 5.6) — rates are per-second, so they scale with dt ---
// Sprint drains 20/s and sustains until stamina reaches 0
if (state == player_states.sprint) {
    stamina = max(0, stamina - 20 * _dt / 60);
    stamina_regen_delay = stamina_regen_delay_max;
    if (stamina <= 0) sprint_needs_reengage = true;
}
// Holding guard counts as blocking — pauses stamina regen
if (state == player_states.block) {
    stamina_regen_delay = stamina_regen_delay_max;
}
// Anti-flutter clears once 30 stamina is banked again
if (sprint_needs_reengage) && (stamina >= 30) {
    sprint_needs_reengage = false;
}
// Stamina regen: 30/s after 0.5 s without sprinting, dodging, or blocking
if (stamina_regen_delay > 0) {
    stamina_regen_delay -= _dt;
} else if (stamina < stamina_max) {
    stamina = min(stamina_max, stamina + 30 * _dt / 60);
}
// Energy regen: 10/s, always
energy = min(energy_max, energy + 10 * _dt / 60);

// After-image ghost lifetime (PRD 5.5)
for (var _gi = array_length(dodge_ghosts) - 1; _gi >= 0; _gi--) {
    dodge_ghosts[_gi].t += _dt;
    if (dodge_ghosts[_gi].t > ghost_life) array_delete(dodge_ghosts, _gi, 1);
}

// Dodge State Activation Trigger — fires on the press frame (PRD 5.5)
// Usable from neutral states, guard, and sword recovery; in the air it is the
// one-per-airtime air dodge. Costs 20 stamina, not fired below 20 (PRD 5.6).
// If unavailable, a held Shift press falls back to a plain sprint above.
if (key_dodge) && (dodge_cooldown <= 0) && (stamina >= 20) {
    var _dodge_ok_state = (state == player_states.idle) || (state == player_states.walk) || (state == player_states.sprint)
        || (state == player_states.jump)
        || (state == player_states.block)
        || (state == player_states.idle_attack_1) || (state == player_states.idle_attack_2) || (state == player_states.idle_attack_3)
        || (state == player_states.walk_attack_1) || (state == player_states.walk_attack_2)
        || (state == player_states.up_attack)     || (state == player_states.down_attack)  || (state == player_states.air_attack);
    if (_dodge_ok_state) {
        var _on_ground = place_meeting(x, y + 1, obj_solid);
        if (_on_ground || !dodge_air_used) {
            state = player_states.dodge;
            image_index = 0;

            // Start timers and pay the dodge cost (PRD 5.6)
            dodge_timer = dodge_duration;
            flash_timer = flash_duration;
            stamina -= 20;
            stamina_regen_delay = stamina_regen_delay_max;
            dodge_ghost_tick = 4;   // first after-image fires on the burst's first dodge step (0/4/8 pattern)
            dodge_was_air = !_on_ground;
            if (!_on_ground) dodge_air_used = true;

            // Contextual Direction Snap: If holding a key, face that direction instantly
            var input_move = key_right - key_left;
            if (input_move != 0) {
                facing_dir = sign(input_move);
            }

            // Cancelling out of a sword swing cleans up its hitbox
            if (attack_hitbox != noone && instance_exists(attack_hitbox)) {
                instance_destroy(attack_hitbox);
                attack_hitbox = noone;
            }
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

// --- HEAVY WEAPON COMMITMENT (PRD 5.8: tap swings the sword, hold swings
// into the heavy) --- At the hold threshold the point of no return passes:
// the current sword swing's remaining recovery is absorbed (its hitbox is
// killed), and the rooted, uninterruptible heavy wind-up begins. Ground-only;
// in the air the hold persists and the commitment starts on the first
// grounded frame if the button is still down ("jump in, plant, swing").
// Never fires without a selected heavy weapon (pre-armory), or out of dodge /
// block / phase slash / wall hang.
if (heavy_weapon != WEAPON.NONE
&&  heavy_hold_timer >= HEAVY_HOLD_THRESHOLD
&&  grounded
&&  state != player_states.heavy_attack
&&  state != player_states.phase_slash
&&  state != player_states.dodge
&&  state != player_states.block
&&  state != player_states.wall_hang) {
    // Absorb: dump the in-flight sword swing's hitbox for a clean re-spawn
    // on the heavy's own hitbox (its per-swing hit_list resets with it)
    if (attack_hitbox != noone && instance_exists(attack_hitbox)) {
        instance_destroy(attack_hitbox);
        attack_hitbox = noone;
    }
    state = player_states.heavy_attack;
    image_index = 0;
    attack_buffered = false;
    heavy_hold_timer = -1;   // commitment absorbed the hold; clear it
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
       (state != player_states.phase_slash)   &&
       (state != player_states.heavy_attack) {   // PRD 5.8: locked in — the attack button itself is ignored
        
        // 1. HIGH PRIORITY SPRINT CHECK: Phase Slash (Works Grounded AND Airborne!)
        // If holding sprint and moving horizontally, execute Phase Slash regardless of altitude
        if (hspd != 0 && key_sprint && phase_slash_cooldown <= 0 && energy >= phase_slash_cost) {
            var _aim_move = key_right - key_left;
            if (_aim_move != 0) facing_dir = sign(_aim_move);
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
            else if (hspd != 0 && key_sprint && state!=player_states.wall_hang && phase_slash_cooldown <= 0 && energy >= phase_slash_cost) {
                var _aim_move = key_right - key_left;
                if (_aim_move != 0) facing_dir = sign(_aim_move);
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
draw_xscale = scr_dt_lerp(draw_xscale, 1, 0.1);
draw_yscale = scr_dt_lerp(draw_yscale, 1, 0.1);

// Manually animate the legs frame counter based on current image speed
legs_image_index += (legs_image_speed * sprite_get_speed(legs_sprite_index) / game_get_speed(gamespeed_fps)) * _dt;

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
	case player_states.heavy_attack:  scr_player_heavy_attack(); break;
}