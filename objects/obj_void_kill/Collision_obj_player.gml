var _p = other;

// Environmental instakill (PRD 4.4, 5.1): bypasses the Overtime State —
// mercies (i-frames, dodge frames, guard) do not apply; a dodge roll into
// a void dies at the bottom of the roll, exactly like touching it walking.
// Not frozen-gated: a pit is static terrain, not a time-freezable hazard.
with (_p) {
    scr_player_true_death();
}
