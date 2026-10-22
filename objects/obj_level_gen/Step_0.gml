if (view_camera[0] == -1) exit;
var _vw  = camera_get_view_width(view_camera[0]);
var _vh  = camera_get_view_height(view_camera[0]);
var _spd = 12;

if (keyboard_check(vk_left))  cam_x -= _spd;
if (keyboard_check(vk_right)) cam_x += _spd;
if (keyboard_check(vk_up))    cam_y -= _spd;
if (keyboard_check(vk_down))  cam_y += _spd;

cam_x = clamp(cam_x, 0, room_width - _vw);
cam_y = clamp(cam_y, 0, room_height - _vh);
camera_set_view_pos(view_camera[0], cam_x, cam_y);