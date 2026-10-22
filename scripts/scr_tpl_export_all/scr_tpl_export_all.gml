/// scr_tpl_export_all — export every chunk that has a header (F4)
function scr_tpl_export_all() {
    var _list = [];
    with (obj_tpl_header) {
        var _cx = floor(x / CHUNK_PITCH_W_PX);
        var _cy = floor(y / CHUNK_PITCH_H_PX);
        var _tpl = scr_tpl_export(_cx, _cy);
        if (_tpl != noone) array_push(_list, _tpl);
    }

    if (array_length(_list) == 0) {
        show_debug_message("scr_tpl_export_all: no templates found.");
        return;
    }

        var _path = working_directory + "templates.json";

    var _f = file_text_open_write(_path);
    file_text_write_string(_f, json_stringify(_list));
    file_text_close(_f);

    show_debug_message("Exported " + string(array_length(_list)) + " templates -> " + _path);
}