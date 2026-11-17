/// obj_enemy_death — enemy corpse (death FX resolve immediately, PRD 5.2)
// Plays the shared death animation once at its authored fps, then holds the
// final frame. Not a child of obj_enemy_parent: corpses are debris — they
// ignore Time Freeze, take no damage, and collide with nothing.
sprite_index = spr_enemy_death;
normal_map = spr_enemy_death_nm;
overlay_sprite = -1;        // Ranger gun / Heavy shield — set by the death hook
facing_dir = 1;
draw_xscale = 1;
draw_yscale = 1;
image_speed = 0;

// Lighting uniforms (same pattern as obj_enemy_parent)
u_light_pos        = shader_get_uniform(shd_normal_map, "u_LightPos");
u_facing_dir       = shader_get_uniform(shd_normal_map, "u_FacingDir");
u_shadow_intensity = shader_get_uniform(shd_normal_map, "u_ShadowIntensity");
u_normal_map       = shader_get_sampler_index(shd_normal_map, "u_NormalMap");
u_light_radius     = shader_get_uniform(shd_normal_map, "u_LightRadius");

shadow_level = 0.4;

gpu_set_texfilter(false);
