/// obj_void_kill — environmental instakill zone (PRD 4.4, 5.1)
///
/// An invisible hitbox the level drops into pit bottoms / crusher paths.
/// Touching it is True Death that BYPASSES the Overtime State entirely —
/// HP is never consulted, i-frames are ignored, scr_player_true_death fires
/// directly (PRD: "Environmental instakill: pits and crushers bypass
/// Overtime into True Death directly").
///
/// Uses spr_void_kill purely as its collision mask (auto rectangle): the
/// placeholder art is a full opaque rect so the bbox covers the whole sprite;
/// resize the sprite for each zone shape. visible = false in the .yy — the
/// sprite is never drawn, in Time Freeze or otherwise (pits are static
/// geometry, not freezable hazards per PRD 5.2's moving-hazard rule).
