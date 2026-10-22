/// scr_tpl_load_all — load exported templates (file must be an Included File)
function scr_tpl_load_all() {
    global.templates = [];
    if (!file_exists("templates.json")) {
        show_debug_message("scr_tpl_load_all: templates.json not found in Included Files");
        return;
    }
    var _f = file_text_open_read("templates.json");
    var _s = "";
    while (!file_text_eof(_f)) {
        _s += file_text_read_string(_f);
        file_text_readln(_f);
    }
    file_text_close(_f);
    global.templates = json_parse(_s);
	    // Normalize exports made before the floor-marker system existed
    for (var _t = 0; _t < array_length(global.templates); _t++) {
        if (!variable_struct_exists(global.templates[_t], "floor_l")) global.templates[_t].floor_l = 21;
        if (!variable_struct_exists(global.templates[_t], "floor_r")) global.templates[_t].floor_r = 21;
    }
    show_debug_message("Loaded " + string(array_length(global.templates)) + " room templates");
}