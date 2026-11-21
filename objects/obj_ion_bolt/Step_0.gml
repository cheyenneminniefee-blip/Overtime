/// obj_ion_bolt — flight + swept collision (PRD 11.1, AC35)

// Time Freeze (PRD 5.2): frozen hostile projectiles do not move
if (global.time_frozen) exit;

// Sub-stepped sweep so a 640 px/s bolt never tunnels a 1-tile wall.
// Per-frame displacement scales with delta time, and the substep count grows
// with it so the sweep granularity (<= 8 px) holds at any step rate.
var _dt = scr_dt();
var _steps = ceil(max(abs(hspd), abs(vspd)) * _dt / 8);
var _dx = hspd * _dt / _steps;
var _dy = vspd * _dt / _steps;
repeat (_steps) {
    x += _dx;
    y += _dy;
    if (place_meeting(x, y, obj_solid)) {
        instance_destroy();
        exit;
    }
}

lifetime -= _dt;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

image_angle = point_direction(0, 0, hspd, vspd);
