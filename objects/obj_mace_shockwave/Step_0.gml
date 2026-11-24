// --- TRAVEL ---
// Straight line away from the strike point, one band above the ground line.
x += wave_dir * MACE_WAVE_SPEED;
wave_travelled += MACE_WAVE_SPEED;

// --- CONTACT: stun + shove whoever the wave front is touching ---
with (obj_enemy_parent) {
    var _already = false;
    for (var _i = 0; _i < array_length(other.hit_list); _i++) {
        if (other.hit_list[_i] == id) { _already = true; break; }
    }
    if (_already) continue;

    // touched by the wave front (vertical band is generous so it connects
    // with enemies standing on the same ground)
    if (abs(y - other.y) > MACE_WAVE_HEIGHT) continue;
    if (abs(x - other.x) > MACE_WAVE_CONTACT) continue;

    // bosses are immune (PRD 5.8; obj_enemy_parent defaults is_boss = false)
    if (is_boss) continue;

    // an enemy in the middle of a HEAVY attack is unaffected and does NOT
    // start the stun-immunity timer (heavies cannot be interrupted — PRD 5.8).
    // No enemy heavy attacks exist yet; heavy_attack_locked is the flag the
    // future enemy heavy system will hold true while its wind-up is committed.
    if (variable_instance_exists(id, "heavy_attack_locked") && heavy_attack_locked) continue;

    // frozen enemies do not flinch or stun (PRD 5.2 parity with the damage path)
    if (global.time_frozen) continue;

    // MELEE wave vs a raised frontal shield: blocked wholly — no stun AND
    // no shove (raised whenever the enemy isn't attacking and isn't stunned,
    // same rule as scr_enemy_take_damage)
    if (blocks_frontal
    &&  state != enemy_states.attack && state != enemy_states.stunned
    &&  sign(other.x - x) == facing_dir) continue;

    // Anti stun-lock core: scr_enemy_stun refuses targets that are already
    // stunned or inside post-stun immunity, and returns false when refused —
    // refused targets must NOT bank the 3 s wave immunity.
    if (scr_enemy_stun(MACE_STUN_DURATION)) {
        wave_stun_immunity = MACE_STUN_IMMUNITY;
        // shove: a slight slide away from the strike. scr_enemy_stun zeroes
        // hspd at entry, so write it AFTER the stun so the stunned loop's
        // knockback decay carries the victim backward instead of dead-stop.
        hspd = other.wave_dir * MACE_WAVE_KNOCKBACK;
        array_push(other.hit_list, id);
    }
}

// --- ANIMATION ---
// Authored-fps playback via manual advance; the 2-frame crack holds its last
// frame for the rest of the crawl.
image_index += sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps);
if (image_index >= image_number) {
    image_index = image_number - 1;
}

// --- END OF RANGE ---
if (wave_travelled >= MACE_WAVE_RANGE) {
    instance_destroy();
}
