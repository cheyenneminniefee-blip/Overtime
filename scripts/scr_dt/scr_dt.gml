/// scr_dt() — the delta-time scale factor for this frame
/// GameMaker runs a fixed logical step rate (this repo: 60/s), but machines
/// that cannot sustain it drop steps and every frame-based calculation
/// degrades into slow motion. This returns how much "one nominal frame"
/// of real time just elapsed, so per-frame velocities and timers can be
/// scaled by it and run in real seconds:
///   1.0  at exactly 60 steps/s (nominal — code behaves unchanged)
///   2.0  at 30 steps/s
/// Clamped on both ends: a multi-second stall (alt-tab, shader compile) may
/// not fling entities through walls, and ultra-high-refresh monitors may not
/// starve the collision sub-stepper. Uses the same value for every instance
/// within a step (delta_time is a per-frame built-in).
function scr_dt() {
    var _factor = delta_time * game_get_speed(gamespeed_fps) / 1000000;
    return clamp(_factor, 0.25, 2.0);
}
