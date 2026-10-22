/// scr_gen_pick_enemy — post-process enemy selection
function scr_gen_pick_enemy() {
    var _pool = [obj_enemy_melee, obj_ranger_enemy, obj_shield_enemy, obj_grenade_enemy];
    return _pool[irandom(array_length(_pool) - 1)];
}