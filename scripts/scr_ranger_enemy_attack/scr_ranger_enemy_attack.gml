// --- RANGER ATTACK STATE ---
function scr_ranger_enemy_attack() {
    // Release frame — the cooldown gate prevents double-fire if frame 3
    // holds for multiple steps
    if (floor(image_index) == 3 && attack_cooldown <= 0) {
        // Projectile creation logic will go here
        attack_cooldown = 60;
    }

    if (image_index >= image_number - 1) {
        state = enemy_states.walk;
    }
}