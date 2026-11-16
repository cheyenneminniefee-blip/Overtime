/// obj_grenade — ballistic flight, fuse, and detonation

// Time Freeze (PRD 5.2): a hostile grenade in flight is frozen solid and
// ticks nothing; a player-thrown grenade keeps flying and detonates on schedule
if (global.time_frozen && !thrown_by_player) exit;

// --- FUSE ---
fuse -= 1;
if (fuse <= 0) {
    scr_grenade_explode(id);
    exit;
}

// --- BALLISTICS with sub-stepped axis resolution (PRD 11.1) ---
vspd += grv;

var _steps = ceil(max(abs(hspd), abs(vspd)) / 8);
var _dx = hspd / _steps;
var _dy = vspd / _steps;
repeat (_steps) {
    if (place_meeting(x + _dx, y, obj_solid)) {
        hspd = -hspd * bounce;
        _dx = 0;
    } else {
        x += _dx;
    }

    if (place_meeting(x, y + _dy, obj_solid)) {
        if (abs(vspd) > 1) {
            vspd = -vspd * bounce;   // 0.5 restitution (PRD 5.6)
            _dy = 0;
        } else {
            vspd = 0;                // settled — rolls to a stop on the ground
            hspd *= 0.85;
            _dy = 0;
        }
    } else {
        y += _dy;
    }
}

image_angle += sign(hspd) * 10;
