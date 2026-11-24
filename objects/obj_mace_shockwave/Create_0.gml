/// obj_mace_shockwave — mace heavy attack: damage-free ground stun wave (PRD 5.8)
/// Spawned once by scr_player_heavy_attack on the mace's authored strike
/// frame (the same frame the 60-damage overhead hitbox goes live). Rules:
///   - deals NO damage — a pure disruption (the overhead strike deals the
///     damage through obj_player_hitbox; never affects the player)
///   - MELEE typing: the Heavy Cyborg's raised frontal shield blocks it
///     wholly — no damage AND no stun
///   - stuns every non-boss enemy in its zone for 1.0 s; each victim then
///     banks 3.0 s of stun immunity (pick up at wake-up via wave_stun_immunity)
///     so a full mace cycle can never stun-lock
///   - an enemy in the middle of a HEAVY attack is unaffected and does not
///     bank the immunity (heavies cannot be interrupted)
depth = -60;       // player and most enemies sit at depth 0; explosion FX use -50
image_speed = 0;   // manual advance only, so image_index never wraps

var _dir = sign(image_xscale);   // the player scales the wedge; sign keeps the strike facing

// The wave resolves instantly — the swing is slow and travel is cosmetic; the
// zone is checked exactly once, here, at the frame of impact.
with (obj_enemy_parent) {
    // grounded band: same ground the player slammed (bodies' origins are
    // near-centre, so the band is generous)
    if (abs(y - other.y) > MACE_WAVE_HEIGHT) continue;

    // forward reach, signed by the strike's facing
    if (x != other.x) {
        if (sign(x - other.x) != _dir) continue;
    }
    if (abs(x - other.x) > MACE_WAVE_RANGE) continue;

    // bosses are immune (PRD 5.8; obj_enemy_parent defaults is_boss = false)
    if (is_boss) continue;

    // an enemy in the middle of a HEAVY attack is unaffected and does NOT
    // start the stun-immunity timer (heavies cannot be interrupted — PRD 5.8).
    // No enemy heavy attacks exist yet; heavy_attack_locked is the flag the
    // future enemy heavy system will hold true while its wind-up is committed.
    if (variable_instance_exists(id, "heavy_attack_locked") && heavy_attack_locked) continue;

    // frozen enemies do not flinch or stun (PRD 5.2 parity with the damage path)
    if (global.time_frozen) continue;

    // MELEE wave vs a raised frontal shield: blocked wholly — no damage AND
    // no stun (same shield rule as scr_enemy_take_damage: raised whenever
    // the enemy isn't attacking and isn't stunned)
    if (blocks_frontal
    &&  state != enemy_states.attack && state != enemy_states.stunned
    &&  sign(other.x - x) == facing_dir) continue;

    // Anti stun-lock core: scr_enemy_stun refuses targets that are already
    // stunned or inside post-stun immunity, and returns false when refused —
    // refused targets must NOT bank the 3 s wave immunity.
    if (scr_enemy_stun(MACE_STUN_DURATION)) {
        wave_stun_immunity = MACE_STUN_IMMUNITY;
    }
}
