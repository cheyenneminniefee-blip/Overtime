/// scr_gen_mask_string(_doors) — e.g. "LRD" for debug messages
function scr_gen_mask_string(_doors) {
    var _s = "";
    if (_doors.l) _s += "L";
    if (_doors.r) _s += "R";
    if (_doors.u) _s += "U";
    if (_doors.d) _s += "D";
    return _s == "" ? "none" : _s;
}