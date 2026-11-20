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
    // VFX LEAD-IN (visual only, no gameplay coupling): the slash graphic
    // spawns the step before the teleport's image_index >= 6 condition first
    // fires — i.e. exactly one frame before the strike — then plays itself
    // out independently (obj_phase_slash_vfx destroys itself at anim end).
    // The window is one step wide and can only pass once before phase_teleported
    // flips, so no guard flag is needed. Player-owned: it animates during a
    // Time Freeze (no gate).
    if (!phase_teleported && image_index < 6
    &&  image_index + sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps) >= 6) {
        var _vfx = instance_create_layer(x, y, layer, obj_phase_slash_vfx);
        _vfx.image_xscale = facing_dir;   // flip-safe either way: a symmetric sprite is unchanged
    }
    if (image_index < 6) {
        hspd = 0;
        vspd = 0;
        phase_teleported = false;
    }
    else if (image_index >= 6) && (!phase_teleported) {
        var teleport_distance = phase_slash_range;   // 160 px — 5 tiles (PRD 5.3)
        var step_check = 0;
        var _travelled = 0;
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
            // Damage every enemy the dash passes through, checked across the
            // 48 px transit corridor (PRD 5.3). Phase Slash bypasses shields
            // entirely (PRD), hence the _bypass flag.
            var _hit = instance_place(x, y, obj_enemy_parent);
            if (_hit == noone) _hit = instance_place(x, y - 16, obj_enemy_parent);
            if (_hit == noone) _hit = instance_place(x, y + 16, obj_enemy_parent);
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
                        // 25 damage, type PHASE — pierces shields via the bypass
                        // flag (PRD 5.3)
                        scr_enemy_take_damage(25, _px, true);
                    }
                }
            }
            _travelled += 1;
        }

        // Cost/cooldown apply only on an actual teleport; a fully blocked path
        // (0 px of travel) fizzles for free (PRD 5.3)
        if (_travelled > 0) {
            phase_slash_cooldown = phase_slash_cd_max;   // 2.0 s (PRD 5.3)
            energy = max(0, energy - 40);                // 40 energy, real teleports only (PRD 5.3, 5.6)
            invuln_timer = max(invuln_timer, 12);        // 0.2 s transit i-frames (PRD 5.3)
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