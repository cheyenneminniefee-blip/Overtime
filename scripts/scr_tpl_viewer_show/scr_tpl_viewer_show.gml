/// scr_tpl_viewer_show — stamp the selected template for inspection
// (uses the calling instance's tpl_index variable)
function scr_tpl_viewer_show() {
    var _tm = layer_tilemap_get_id(layer_get_id("Tiles_runtime"));
    scr_tilemap_fill(_tm, 0);   // was: tilemap_fill(_tm, 0);

    // Stamping spawns solids now — clean up the previous preview's set
    with (obj_solid_tile) instance_destroy();

    scr_tpl_stamp(global.templates[tpl_index], 0, 0);
    show_debug_message("Viewing [" + string(tpl_index + 1) + "/" +
                       string(array_length(global.templates)) + "]: " +
                       global.templates[tpl_index].name +                       " | floor: " + string(global.templates[tpl_index].floor_l) +
                       "->" + string(global.templates[tpl_index].floor_r) +
                       " | doors: " + json_stringify(global.templates[tpl_index].doors) +
                       " | tags: " + json_stringify(global.templates[tpl_index].tags));
}