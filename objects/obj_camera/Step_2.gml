// Safety check: If the player is dead or missing, don't execute camera math
if (!instance_exists(target)) exit;

// 1. CALCULATE LOOK-AHEAD (PEEK)
// Use the player's facing_dir variable from your state machine to decide which way to peek
var target_peek = target.facing_dir * peek_max_dist;

// Smoothly slide the peek offset toward the target direction
peek_offset_x = lerp(peek_offset_x, target_peek, peek_speed);


// 2. DETERMINE TARGET POSITION
// Center the camera on the player, then apply our horizontal peek offset
var target_x = target.x - (cam_width / 2) + peek_offset_x;
var target_y = target.y - (cam_height / 2);


// 3. SMOOTH CAMERA GLIDE (INTERPOLATION)
// Grab where the camera currently is in the room
var current_x = camera_get_view_x(view_camera[0]);
var current_y = camera_get_view_y(view_camera[0]);

// Lerp from current position toward target position
var new_x = lerp(current_x, target_x, follow_speed);
var new_y = lerp(current_y, target_y, follow_speed);


// 4. BOUNDARY CLAMPING
// Prevent the camera from showing the empty 'void' outside your room borders
new_x = clamp(new_x, 0, room_width - cam_width);
new_y = clamp(new_y, 0, room_height - cam_height);


// 5. APPLY POSITION
camera_set_view_pos(view_camera[0], new_x, new_y);