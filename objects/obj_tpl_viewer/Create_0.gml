if (!variable_global_exists("templates")) {
    scr_tpl_load_all();
}
tpl_index = 0;

if (array_length(global.templates) > 0) {
    scr_tpl_viewer_show();
} else {
    show_debug_message("obj_tpl_viewer: no templates loaded — export some first (F4 in rm_workshop)");
}