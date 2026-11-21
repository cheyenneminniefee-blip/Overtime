/// obj_ion_bolt — flight + swept collision (PRD 11.1, AC35)

// Time Freeze (PRD 5.2): frozen hostile projectiles do not move
if (global.time_frozen) exit;

// Sub-stepped sweep so a 640 px/s bolt never tunnels a 1-tile wall
var _steps = ceil(max(abs(hspd), abs(vspd)) / 8);
var _dx = hspd / _steps;
var _dy = vspd / _steps;
repeat (_steps) {
    x += _dx;
    y += _dy;
    if (place_meeting(x, y, obj_solid)) {
        instance_destroy();
        exit;
    }
}

lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

image_angle = point_direction(0, 0, hspd, vspd);
