// --- GRENADE ENEMY ATTACK STATE ---
function scr_grenade_enemy_attack() {
    // Release frame — the cooldown gate prevents double-fire if frame 3
    // holds for multiple steps
    if (floor(image_index) == 3 && attack_cooldown <= 0) {
        if (instance_exists(obj_player)) {
            var _throw_x = x + facing_dir * 10;
            var _throw_y = y - 20;
            var _g = instance_create_layer(_throw_x, _throw_y, layer, obj_grenade);
            _g.owner = id;

            // Ballistic lob resolved onto the player's current position
            // (PRD 7.2 — lobs physics grenades; friendly fire is the exploit vector)
            var _dx = obj_player.x - _throw_x;
            var _dy = (obj_player.y - 8) - _throw_y;
            var _t = clamp(abs(_dx) / 3, 30, 66);   // flight time in frames, capped by the fuse
            _g.hspd = _dx / _t;
            _g.vspd = (_dy - 0.5 * _g.grv * _t * _t) / _t;
        }
        attack_cooldown = 240;   // 4.0 s at 60 fps (PRD 7.2)
    }

    if (image_index >= image_number - 1) {
        state = enemy_states.walk;
    }
}
