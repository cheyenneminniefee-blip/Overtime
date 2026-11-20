/// obj_phase_slash_vfx — Phase Slash visual effect (spr_phase_slash)
/// Pure VFX: no damage, no collisions, no gameplay coupling. The player
/// spawns it one frame before the Phase Slash teleport executes; this
/// instance plays the sprite once (art fps, manual advance) and destroys
/// itself the moment the animation completes.
///
/// Player-owned visual: it animates and resolves during Time Freeze (the
/// player is operational mid-freeze, and death FX resolve immediately per
/// PRD 5.2) — no freeze gate here.
depth = -60;   // player and most enemies sit at depth 0; explosion FX use -50
sprite_index = spr_phase_slash;
image_speed = 0;          // manual advance only, so image_index never wraps
