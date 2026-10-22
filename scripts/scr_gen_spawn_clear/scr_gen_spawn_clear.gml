/// scr_gen_spawn_clear(_x, _y, _obj) — create _obj and lift it until clear
// of solids (max 256 px). An enemy marker placed a tile too low still lands
// on the surface instead of inside it. Returns the instance id.
function scr_gen_spawn_clear(_x, _y, _obj) {
    var _inst = instance_create_layer(_x, _y, layer_get_id("Instances"), _obj);
    var _lift = 0;
    while (_lift < 256) {
        var _clear = true;
        with (_inst) {
            if (place_meeting(x, y, obj_solid)) _clear = false;
        }
        if (_clear) break;
        _inst.y -= 1;
        _lift++;
    }
    return _inst;
}