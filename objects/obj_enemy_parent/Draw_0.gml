// --- 0. HIT FLASH OVERRIDE ---
// While flash_timer is active, draw as a white silhouette instead of
// normal-mapped shading — 4 frames of punchy damage feedback.
var _flashing = (flash_timer > 0);
var shader_active = false;

if (_flashing) {
    shader_set(shd_flash);
    shader_set_uniform_f(u_flash, flash_timer / flash_duration);
    shader_active = true;
}

// --- 1. FIND THE CLOSEST LIGHT ---
var light_x = x;
var light_y = y - 100;
var light_z = 30;
var light_radius = 200;

if (!_flashing) {
    var active_light = instance_nearest(x, y, obj_light);
    if (active_light != noone) {
        light_x = active_light.x;
        light_y = active_light.y;
        light_z = variable_instance_exists(active_light, "light_height") ? active_light.light_height : 30;

        if (variable_instance_exists(active_light, "light_max_radius")) {
            light_radius = active_light.light_max_radius;
        }
    }
}

// --- 2. SQUASH & STRETCH MATH ---
var origin_to_bottom = sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index);
var y_offset = origin_to_bottom * (1 - draw_yscale);

// --- 3. CHECK ASSET AVAILABILITY ---
var body_has_nm = sprite_exists(normal_map);
var legs_has_nm = sprite_exists(leg_normal_map);

// --- 4. DRAW LOWER BODY (LEGS) LAYER ---
// Legs hidden during attack AND stun (full-body sprites)
if (state != enemy_states.attack && state != enemy_states.stunned && sprite_exists(legs_sprite_index)) {

    if (legs_has_nm && !shader_active) {
        shader_set(shd_normal_map);
        shader_set_uniform_f(u_light_pos, light_x, light_y, light_z);
        shader_set_uniform_f(u_facing_dir, facing_dir);
        shader_set_uniform_f(u_shadow_intensity, shadow_level);
        shader_set_uniform_f(u_light_radius, light_radius);
        shader_active = true;
    }

    if (legs_has_nm && !_flashing) {
        texture_set_stage(u_normal_map, sprite_get_texture(leg_normal_map, legs_image_index));
    }

    draw_sprite_ext(legs_sprite_index, legs_image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, image_angle, image_blend, image_alpha);
}

// --- 5. DRAW MAIN BODY LAYER ---
if (sprite_exists(sprite_index)) {

    if (!shader_active && body_has_nm) {
        shader_set(shd_normal_map);
        shader_set_uniform_f(u_light_pos, light_x, light_y, light_z);
        shader_set_uniform_f(u_facing_dir, facing_dir);
        shader_set_uniform_f(u_shadow_intensity, shadow_level);
        shader_set_uniform_f(u_light_radius, light_radius);
        shader_active = true;
    } else if (shader_active && !_flashing && !body_has_nm) {
        // NM shader is running from the legs but the body has no normal map —
        // drop it so the body doesn't inherit the legs' texture
        shader_reset();
        shader_active = false;
    }

    if (body_has_nm && !_flashing) {
        texture_set_stage(u_normal_map, sprite_get_texture(normal_map, image_index));
    }

    draw_sprite_ext(sprite_index, image_index, x, y + y_offset,
        facing_dir * draw_xscale, draw_yscale, image_angle, image_blend, image_alpha);
}

// --- 6. CLEAN UP ---
if (shader_active) shader_reset();