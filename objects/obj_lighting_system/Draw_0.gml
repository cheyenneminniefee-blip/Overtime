// 1. GET THE ACCURATE CAMERA POSITION
// We pull directly from your camera tracking variables
// --- 1. GET THE ACCURATE CAMERA POSITION & SIZE ---
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);  // FIX: Changed from size_x to width
var _cam_h = camera_get_view_height(view_camera[0]); // FIX: Changed from size_y to height
// 2. SURFACE MANAGMENT
if (!surface_exists(lighting_surface)) {
    lighting_surface = surface_create(_cam_w, _cam_h);
}

// Target our surface and clear it to total darkness
surface_set_target(lighting_surface);
draw_clear_alpha(c_black, 0.85); // Adjust 0.85 to change how dark your shadows/nighttime look

// 3. PUNCH OUT LIGHT VOLUMES (Subtract blend mode)
gpu_set_blendmode(bm_subtract);

with (obj_light) {
    // FIX: Subtract the camera position so the light's room coordinates 
    // translate accurately to the surface's local pixel space!
    var _surface_lx = x - _cam_x;
    var _surface_ly = y - _cam_y;
    
    // Draw the light volume relative to the screen frame
    draw_circle_color(_surface_lx, _surface_ly, light_radius, c_white, c_black, false);
}

gpu_set_blendmode(bm_normal);

// 4. PROJECT GEOMETRIC SHADOWS (Raycasting shadow blocks)
// If you have walls or pillars blocking light, they are drawn here
with (obj_solid) {
    var _light = instance_nearest(x, y, obj_light);
    if (_light != noone) {
        // Find angle from the light source to this object
        var _dir = point_direction(_light.x, _light.y, x, y);
        
        draw_set_color(c_black);
        draw_set_alpha(1.0);
        
        // FIX: Translate this object's coordinates to surface space
        var _sx = x - _cam_x;
        var _sy = y - _cam_y;
        
        // Project a shadow block away into the distance
        var _len = 2000; 
        var _bx = _sx + lengthdir_x(_len, _dir);
        var _by = _sy + lengthdir_y(_len, _dir);
        
        // Simple placeholder line shadow for structural testing
        // (For robust volumetric shadows, you'd stretch a polygon here)
        draw_line_width(_sx, _sy, _bx, _by, 32); 
    }
}

// Restore rendering back to the standard game screen frame buffer
surface_reset_target();

// 5. DRAW COMPOSITE SHADOW MAP OVER THE ROOM
// We lock the drawing to true view screen space using standard multiplicative blending
gpu_set_blendmode(bm_src_color); 
draw_surface(lighting_surface, _cam_x, _cam_y);
gpu_set_blendmode(bm_normal);