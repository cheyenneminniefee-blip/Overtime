/// obj_time_domain — freeze countdown (PRD 5.2: 5 s duration, 30 s cooldown
/// starting at activation, one charge, no stacking). When PAUSE / DIALOGUE /
/// HITSTOP land, their states hold this countdown here.
if (freeze_cd_timer > 0) freeze_cd_timer -= 1;

if (global.time_state == TIME.FROZEN) {
    freeze_timer -= 1;
    if (freeze_timer <= 0) {
        scr_freeze_set(false);
    }
}
