var _enemy = other;

// One hit per enemy per swing
var _already_hit = false;
for (var i = 0; i < array_length(hit_list); i++) {
    if (hit_list[i] == _enemy) {
        _already_hit = true;
        break;
    }
}
if (_already_hit) exit;

array_push(hit_list, _enemy);

var _dmg = damage;
var _src_x = x;   // hitbox tracks the player exactly, so this IS the swing origin
with (_enemy) {
    scr_enemy_take_damage(_dmg, _src_x, false);
}