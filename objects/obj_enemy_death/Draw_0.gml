/// obj_enemy_death — corpse draw: normal-mapped death anim + frame-aligned prop
// Same lighting pipeline as the living enemies' body layer.

// --- 1. FIND THE CLOSEST LIGHT ---
var light_x = x;
var light_y = y - 100;
var light_z = 30;
var light_radius = 200;

var active_light = instance_nearest(x, y, obj_light);
if (active_light != noone) {
    light_x = active_light.x;
    light_y = active_light.y;
    light_z = variable_instance_exists(active_light, "light_height") ? active_light.light_height : 30;
    if (variable_instance_exists(active_light, "light_max_radius")) {
        light_radius = active_light.light_max_radius;
    }
}

// --- 2. SQUASH & STRETCH MATH (same as obj_enemy_parent) ---
var origin_to_bottom = sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index);
var y_offset = origin_to_bottom * (1 - draw_yscale);

// --- 3. BODY ---
if (sprite_exists(normal_map)) {
    shader_set(shd_normal_map);
    shader_set_uniform_f(u_light_pos, light_x, light_y, light_z);
    shader_set_uniform_f(u_facing_dir, facing_dir);
    shader_set_uniform_f(u_shadow_intensity, shadow_level);
    shader_set_uniform_f(u_light_radius, light_radius);
    texture_set_stage(u_normal_map, sprite_get_texture(normal_map, image_index));
    draw_sprite_ext(sprite_index, image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, 0, image_blend, 1);
    shader_reset();
} else {
    draw_sprite_ext(sprite_index, image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, 0, image_blend, 1);
}

// --- 4. PROP OVERLAY (ranger gun / heavy shield) ---
// Frame-aligned: same image_index as the death animation, no normal map
if (overlay_sprite != -1) {
    draw_sprite_ext(overlay_sprite, image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, 0, image_blend, 1);
}
