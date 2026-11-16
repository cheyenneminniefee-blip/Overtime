/// scr_grenade_explode(_grenade_id) — one grenade detonation
// PRD 5.6 / 6.3: 30 dmg EXPLOSIVE, 72 px blast, friendly fire ON — damages
// the player, regular enemies, and the thrower is not special-cased ("hurt
// everyone"). PRD 6.2: EXPLOSIVE bypasses the Heavy Cyborg shield and cannot
// be guarded (AC37). PRD 6.7: nearby explosives arm with a 3 f delay.
function scr_grenade_explode(_id) {

    var _bx = _id.x;
    var _by = _id.y;
    var _r = _id.blast_radius;
    var _dmg = _id.damage;

    // --- PLAYER (guard never blocks EXPLOSIVE — PRD 6.2, AC37) ---
    if (instance_exists(obj_player)) {
        with (obj_player) {
            if (point_distance(x, y, _bx, _by) <= _r + 8) {
                scr_player_take_damage(_dmg, _bx);
            }
        }
    }

    // --- ENEMIES (friendly fire ON — PRD 6.3, AC10) ---
    // scr_enemy_take_damage handles the shield bypass, the frozen 0.5x
    // multiplier, kill credit, and drops
    with (obj_enemy_parent) {
        if (point_distance(x, y, _bx, _by) <= _r + 16) {
            scr_enemy_take_damage(_dmg, _bx, true);
        }
    }

    // --- SYMPATHETIC DETONATION (PRD 6.7) ---
    // Other explosives inside the blast arm with a 3 f delay, then detonate
    with (obj_grenade) {
        if (id != _id && fuse > 3) {
            fuse = 3;
        }
    }

    with (_id) {
        instance_destroy();
    }
}
