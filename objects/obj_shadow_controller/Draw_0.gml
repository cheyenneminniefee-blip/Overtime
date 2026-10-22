// 1. GET ACCURATE VIEW COORDINATES
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

// 2. REBUILD SURFACE IF IT DROPS FROM GPU MEMORY
if (!surface_exists(shadow_surface)) {
    shadow_surface = surface_create(_cam_w, _cam_h);
}

// Target our surface and clear it to a dark ambient nighttime shroud
surface_set_target(shadow_surface);
draw_clear_alpha(c_black, 0.85); // 0.85 = 85% opacity darkness. 1.0 = pitch black.

// 3. PUNCH HOLES FOR VISIBLE LIGHTS
gpu_set_blendmode(bm_subtract);
with (obj_light) {
    var _lx = x - _cam_x;
    var _ly = y - _cam_y;
    // Clears a circle of darkness so the normal-mapped game world shows through underneath
    draw_circle_color(_lx, _ly, light_radius, c_white, c_black, false);
}
gpu_set_blendmode(bm_normal);


// 4. PROJECT DYNAMIC PLAYER SHADOWS
// We treat the player's bounding box as a solid wall blocking the light source
with (obj_player) {
    var _light = instance_nearest(x, y, obj_light);
    if (_light != noone) {
        
        // Find the bounding edges of the player in room space
        var _px1 = bbox_left;
        var _px2 = bbox_right;
        var _py1 = bbox_top;
        var _py2 = bbox_bottom;
        
        // Calculate projection directions from the center of the light source to the player edges
        var _dir1 = point_direction(_light.x, _light.y, _px1, _py2); // Bottom-left corner
        var _dir2 = point_direction(_light.x, _light.y, _px2, _py2); // Bottom-right corner
        
        // Convert those edge points into screen/surface space
        var _sx1 = _px1 - _cam_x;
        var _sy1 = _py2 - _cam_y;
        var _sx2 = _px2 - _cam_x;
        var _sy2 = _py2 - _cam_y;
        
        // Push the shadow projection points deep into the background (2000 pixels away)
        var _dist = 2000;
        var _bx1 = _sx1 + lengthdir_x(_dist, _dir1);
        var _by1 = _sy1 + lengthdir_y(_dist, _dir1);
        var _bx2 = _sx2 + lengthdir_x(_dist, _dir2);
        var _by2 = _sy2 + lengthdir_y(_dist, _dir2);
        
        // Draw the solid dark shadow polygon extending away from the light source
        draw_set_color(c_black);
        draw_set_alpha(1.0);
        
        // Build the shadow volume using two connected primitive triangles
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex(_sx1, _sy1); // Base point 1 (Feet left)
        draw_vertex(_bx1, _by1); // Projected point 1
        draw_vertex(_sx2, _sy2); // Base point 2 (Feet right)
        draw_vertex(_bx2, _by2); // Projected point 2
        draw_primitive_end();
    }
}

// 5. RESTORE THE SCREEN FRAME BUFFER
surface_reset_target();

// Multiply our composite shadow canvas back over the game room flawlessly
gpu_set_blendmode(bm_src_color); 
draw_surface(shadow_surface, _cam_x, _cam_y);
gpu_set_blendmode(bm_normal);