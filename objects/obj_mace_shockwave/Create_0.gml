/// obj_mace_shockwave — mace heavy attack: travelling ground stun wave (PRD 5.8)
/// Spawned once by scr_player_heavy_attack on the mace's authored strike
/// frame (the same frame the 60-damage overhead hitbox goes live). The wave
/// then CRAWLS away from the player in a straight line, and every non-boss
/// enemy it touches is stunned and shoved backward slightly. Rules:
///   - deals NO damage — the overhead strike deals the damage through
///     obj_player_hitbox; never affects the player
///   - MELEE typing: the Heavy Cyborg's raised frontal shield blocks it
///     wholly — no stun AND no shove
///   - 1.0 s stun on contact (MACE_STUN_DURATION); each victim then banks
///     3.0 s of stun immunity (MACE_STUN_IMMUNITY, paid at wake-up via
///     wave_stun_immunity) so a full mace cycle can never stun-lock
///   - an enemy in the middle of a HEAVY attack is unaffected and does not
///     bank the immunity (heavies cannot be interrupted)
depth = -60;       // player and most enemies sit at depth 0; explosion FX use -50
image_speed = 0;   // manual advance only, so image_index never wraps

wave_dir = 1;        // travel direction — set by the spawner (facing_dir) AFTER create;
                     // Create can't read the spawner's image_xscale, it runs first
wave_travelled = 0;  // px crawled so far (destroyed at MACE_WAVE_RANGE)
hit_list = [];       // enemies already stunned by THIS wave (no re-stuns)
