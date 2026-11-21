/// scr_dt_lerp(_from, _to, _k) — framerate-corrected lerp
/// The codebase uses per-frame exponential lerps (lerp(a, b, 0.1)), whose
/// convergence speed depends on how many steps run per real second. This
/// converts a per-frame lerp factor into a per-second one, so "0.1 per
/// frame at 60 fps" converges at the same real-time rate at ANY step rate.
/// At 60 fps the result is identical to lerp(_from, _to, _k).
function scr_dt_lerp(_from, _to, _k) {
    var _factor = 1 - power(1 - _k, scr_dt());
    return lerp(_from, _to, _factor);
}
