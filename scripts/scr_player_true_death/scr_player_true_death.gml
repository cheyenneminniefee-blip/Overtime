/// scr_player_true_death() — True Death (PRD 5.1)
// Timer expiry or unguarded damage during Overtime. Plays the player death
// animation, then holds the final frame. deaths++ and the Afterlife arrive
// with their systems (currently out of scope).
function scr_player_true_death() {
    var _corpse = instance_create_layer(x, y, layer, obj_player_death);
    _corpse.facing_dir = facing_dir;
    instance_destroy();
}
