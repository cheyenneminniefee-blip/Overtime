function scr_player_phase_slash() {
    sprite_index = spr_player_phase;
    image_speed = 1;

    normal_map = spr_player_phase_nm;

    var grounded = place_meeting(x, y + 1, obj_solid);

    // --- 1. LEGS HANDLING ---
    legs_sprite_index = spr_player_legs_idle;
    legs_image_index = 0;
    legs_image_speed = 0;

    // --- 2. THE TIMED TELEPORT MECHANIC ---
    if (image_index < 6) {
        hspd = 0;
        vspd = 0;
        phase_teleported = false;
    }
    else if (image_index >= 6) && (!phase_teleported) {
        var teleport_distance = 192;
        var step_check = 0;
        var phase_hits = [];   // Enemies already pierced during this dash
        var _px = x;           // Where the strike originated

        while (step_check < teleport_distance) {
            var target_x = x + sign(facing_dir);

            if (place_meeting(target_x, y, obj_solid)) {
                break;
            }

            x = target_x;
            step_check += 1;

            // --- PIERCING STRIKE ---
            // Damage every enemy the dash passes through. Phase Slash
            // bypasses shields entirely (PRD), hence the _bypass flag.
            var _hit = instance_place(x, y, obj_enemy_parent);
            if (_hit != noone) {
                var _already = false;
                for (var i = 0; i < array_length(phase_hits); i++) {
                    if (phase_hits[i] == _hit) {
                        _already = true;
                        break;
                    }
                }
                if (!_already) {
                    array_push(phase_hits, _hit);
                    with (_hit) {
                        scr_enemy_take_damage(1, _px, true);
                    }
                }
            }
        }

        phase_teleported = true;
    }

    // --- 3. ANIMATION TERMINATION HANDSHAKE ---
    if (image_index >= image_number - 1) {
        phase_teleported = false;
        attack_cooldown = 15;

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