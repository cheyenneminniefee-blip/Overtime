/// scr_grenade_explode(_grenade_id) — one grenade detonation
// PRD 5.6 / 6.3: 30 dmg EXPLOSIVE, 72 px blast, friendly fire ON — damages
// the player, regular enemies, and the thrower is not special-cased ("hurt
// everyone"). PRD 6.2: EXPLOSIVE bypasses the Heavy Cyborg shield and cannot
// be guarded (AC37). PRD 6.7: sympathetic detonation with chain caps.
function scr_grenade_explode(_id) {

    // --- CHAIN CAPS (PRD 6.7) ---
    // get_timer() buckets detonations: those < 1 frame apart share a frame,
    // and 0.5 s without a detonation starts a new chain.
    var _now = get_timer();
    if (_now - global.last_detonate_us > 16667) {
        global.detonations_frame = 0;
    }
    if (_now - global.detonation_chain_start_us > 500000) {
        global.detonation_chain_count = 0;
        global.detonation_chain_start_us = _now;
    }
    global.last_detonate_us = _now;

    var _bx = _id.x;
    var _by = _id.y;
    var _r = _id.blast_radius;
    var _dmg = _id.damage;
    var _layer = _id.layer;

    // Beyond 8 detonations per chain: visual dud (PRD 6.7) — puff, no damage,
    // no sympathetic arming
    if (global.detonation_chain_count >= 8) {
        instance_create_layer(_bx, _by, _layer, obj_explosion);
        with (_id) {
            instance_destroy();
        }
        return;
    }

    // Over 4 detonations this frame: deferred — the grenade stays armed and
    // retries next frame (its fuse is already at 0)
    if (global.detonations_frame >= 4) return;

    global.detonations_frame += 1;
    global.detonation_chain_count += 1;

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

    // --- BLAST VISUAL ---
    // spr_explosion has a centered origin, so spawning at the blast point
    // keeps the puff centered as it grows to the 72 px radius
    instance_create_layer(_bx, _by, _layer, obj_explosion);

    with (_id) {
        instance_destroy();
    }
}
