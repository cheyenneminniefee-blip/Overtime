/// obj_player_death — True Death corpse (same contract as obj_enemy_death)
// Plays spr_player_death once at its authored fps, then holds the final frame.
// Debris: no collisions, no interactions; the Afterlife consumes this later.
sprite_index = spr_player_death;
facing_dir = 1;
image_speed = 0;

gpu_set_texfilter(false);
