// --- 1. FIND THE CLOSEST LIGHT ---
var active_light = instance_nearest(x, y, obj_light);
var light_x = x;
var light_y = y - 100;
var light_z = 30;
var light_radius = 200;

if (active_light != noone) {
    light_x = active_light.x;
    light_y = active_light.y;
    light_z = variable_instance_exists(active_light, "light_height") ? active_light.light_height : 30;

    if (variable_instance_exists(active_light, "light_max_radius")) {
        light_radius = active_light.light_max_radius;
    }
}

// --- 2. SQUASH & STRETCH MATH ---
var origin_to_bottom = sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index);
var y_offset = origin_to_bottom * (1 - draw_yscale);

// --- 3. PICK THE SHADER (white flash overrides lighting) ---
if (flash_timer > 0) {
    shader_set(shd_flash);
    shader_set_uniform_f(u_flash, flash_timer / flash_duration);
} else {
    shader_set(shd_normal_map);
    shader_set_uniform_f(u_light_pos, light_x, light_y, light_z);
    shader_set_uniform_f(u_facing_dir, facing_dir);
    shader_set_uniform_f(u_shadow_intensity, shadow_level);
    shader_set_uniform_f(u_light_radius, light_radius);   // BUG FIX: was never sent
}

// Mercy invulnerability blink
var _alpha = image_alpha;
if (invuln_timer > 0 && (invuln_timer mod 8) < 4) {
    _alpha *= 0.35;
}

// --- 4. DRAW LOWER BODY (LEGS) LAYER ---
if (state != player_states.idle_attack_1) &&
   (state != player_states.idle_attack_2) &&
   (state != player_states.idle_attack_3) &&
   (state != player_states.phase_slash)   &&
   (state != player_states.dodge)         &&
   (state != player_states.wall_hang)     &&
   (state != player_states.block) {

    if (sprite_exists(legs_sprite_index)) {
        if (flash_timer <= 0) {
            var legs_nm_tex = sprite_get_texture(leg_normal_map, legs_image_index);
            texture_set_stage(u_normal_map, legs_nm_tex);
        }

        draw_sprite_ext(legs_sprite_index, legs_image_index, x, y + y_offset,
            facing_dir * draw_xscale, draw_yscale, image_angle, image_blend, _alpha);
    }
}

// --- 5. DRAW MAIN BODY LAYER ---
if (sprite_exists(sprite_index)) {
    if (flash_timer <= 0) {
        var body_nm_tex = sprite_get_texture(normal_map, image_index);
        texture_set_stage(u_normal_map, body_nm_tex);
    }

    draw_sprite_ext(sprite_index, image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, image_angle, image_blend, _alpha);
}

shader_reset();