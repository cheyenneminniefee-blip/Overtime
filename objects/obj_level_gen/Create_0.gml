var _ly = layer_get_id("Tiles_runtime");
var _tm = (_ly == -1) ? -1 : layer_tilemap_get_id(_ly);
show_debug_message("=== GENERATION DIAGNOSTICS ===");
show_debug_message("layer handle: " + string(_ly) + "  (-1 = layer name is not exactly 'Tiles_runtime')");
show_debug_message("tilemap handle: " + string(_tm) + "  (-1 = layer exists but is not a tile layer)");
show_debug_message("room size: " + string(room_width) + " x " + string(room_height));
show_debug_message("needed size: " + string(GEN_GRID_W * CHUNK_W_PX) + " x " + string(GEN_GRID_H * CHUNK_H_PX));

if (!variable_global_exists("templates")) {
    scr_tpl_load_all();
}

seed       = 137;
last_rooms = scr_level_generate("above", 15, seed);

// Park the camera on the entrance (grid cell 1, row 2)
if (view_camera[0] != -1) {
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    cam_x = clamp(1 * CHUNK_W_PX + CHUNK_W_PX / 2 - _vw / 2, 0, room_width - _vw);
    cam_y = clamp(2 * CHUNK_H_PX + CHUNK_H_PX / 2 - _vh / 2, 0, room_height - _vh);
    camera_set_view_pos(view_camera[0], cam_x, cam_y);
}