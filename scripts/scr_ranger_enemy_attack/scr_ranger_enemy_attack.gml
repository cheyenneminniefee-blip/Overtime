// --- RANGER ATTACK STATE ---
function scr_ranger_enemy_attack() {
    // Release frame — the cooldown gate prevents double-fire if frame 3
    // holds for multiple steps
    if (floor(image_index) == 5 && attack_cooldown <= 0) {
        if (instance_exists(obj_player)) {
            var _muzzle_y = y - 12;
            var _bolt = instance_create_layer(x + facing_dir * 12, _muzzle_y, layer, obj_ion_bolt);
            _bolt.owner = id;

            // Linear shot straight at the player (PRD 7.2 — no arc, no gravity)
            var _dir = point_direction(x, _muzzle_y, obj_player.x, obj_player.y - 12);
            _bolt.hspd = lengthdir_x(_bolt.move_spd, _dir);
            _bolt.vspd = lengthdir_y(_bolt.move_spd, _dir);
        }
        attack_cooldown = 120;   // 2.0 s at 60 fps (PRD 7.2)
    }

    if (image_index >= image_number - 1) {
        state = enemy_states.walk;
    }
}
