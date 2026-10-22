// --- GRENADE ENEMY ATTACK STATE ---
function scr_grenade_enemy_attack() {
    if (floor(image_index) == 3 && attack_cooldown <= 0) {
        // Grenade creation / throw logic will go here
        attack_cooldown = 90;
    }

    if (image_index >= image_number - 1) {
        state = enemy_states.walk;
    }
}