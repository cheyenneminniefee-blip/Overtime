var _e = other;

// ION never strikes an enemy on its own (PRD 6.3 friendly-fire matrix) —
// only a bolt reflected by a perfect parry is player-owned and damages enemies
if (!reflected) exit;

var _dmg = damage;
var _src_x = x;
instance_destroy();
with (_e) {
    scr_enemy_take_damage(_dmg, _src_x, false);
}
