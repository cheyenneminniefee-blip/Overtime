/// scr_player_throw_grenade() — Photon Grenade throw (PRD 5.7)
// Instant free action on the G press: no state change, works from any state.
// Carry limit 3 (resupply at checkpoints — wired when obj_checkpoint lands).
function scr_player_throw_grenade() {
    if (!has_grenades || grenades <= 0) return;

    grenades -= 1;

    var _throw_x = x + facing_dir * 12;
    var _throw_y = y - 20;
    var _g = instance_create_layer(_throw_x, _throw_y, layer, obj_grenade);
    _g.owner = id;
    _g.thrown_by_player = true;   // Keeps flying and detonates during a Time Freeze (PRD 5.2)

    // 420 px/s on a fixed 45-degree arc (PRD 5.7) — 7 px/frame at 60 fps
    var _spd = 420 / 60;
    _g.hspd = facing_dir * _spd * cos(45);
    _g.vspd = -_spd * sin(45);
}
