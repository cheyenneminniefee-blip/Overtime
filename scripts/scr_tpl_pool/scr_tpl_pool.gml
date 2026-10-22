/// scr_tpl_pool(_biome, _doors, _tags, _fl, _fr, _tol)
// _fl/_fr: required edge floor rows, or -1 for "any". _tol: allowed seam step.
function scr_tpl_pool(_biome, _doors, _tags, _fl, _fr, _tol) {
    var _out = [];
    for (var i = 0; i < array_length(global.templates); i++) {
        var _t = global.templates[i];
        if (_t.biome != _biome) continue;
        if (_t.doors.l != _doors.l) continue;
        if (_t.doors.r != _doors.r) continue;
        if (_t.doors.u != _doors.u) continue;
        if (_t.doors.d != _doors.d) continue;
        if (_fl != -1 && abs(_t.floor_l - _fl) > _tol) continue;
        if (_fr != -1 && abs(_t.floor_r - _fr) > _tol) continue;
        var _ok = true;
        for (var j = 0; j < array_length(_tags); j++) {
            if (!array_contains(_t.tags, _tags[j])) { _ok = false; break; }
        }
        if (!_ok) continue;
        array_push(_out, _t);
    }
    return _out;
}