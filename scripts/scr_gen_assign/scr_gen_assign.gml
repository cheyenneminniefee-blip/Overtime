/// scr_gen_assign(_biome, _cell, _tags_pref, _need_l, _need_r)
// _need_l/_need_r: edge heights required by already-assigned neighbors, or -1.
// Fallback: exact height + tags → exact + no tags → ±2 seam (jumpable) → free
// (picked only if the mask exists at NO height; the seam audit will flag it).
function scr_gen_assign(_biome, _cell, _tags_pref, _need_l, _need_r) {
    var _doors = { l: _cell.l, r: _cell.r, u: _cell.u, d: _cell.d };
    var _pool = scr_tpl_pool(_biome, _doors, _tags_pref, _need_l, _need_r, 0);
    if (array_length(_pool) == 0) _pool = scr_tpl_pool(_biome, _doors, [], _need_l, _need_r, 0);
    if (array_length(_pool) == 0) _pool = scr_tpl_pool(_biome, _doors, _tags_pref, _need_l, _need_r, 2);
    if (array_length(_pool) == 0) _pool = scr_tpl_pool(_biome, _doors, [], _need_l, _need_r, 2);

    if (array_length(_pool) == 0) {
        show_debug_message("NO TEMPLATE: biome '" + _biome + "', mask '" +
            scr_gen_mask_string(_doors) + "', floor L" + string(_need_l) +
            "/R" + string(_need_r) + ", tags " + json_stringify(_tags_pref) +
            " — author one and re-export (F4).");
        return noone;
    }
    return _pool[irandom(array_length(_pool) - 1)];
}