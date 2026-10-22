// Kill any live attack hitbox so it doesn't outlive the enemy
// (previously, an enemy destroyed mid-attack leaked its hitbox forever)
if (instance_exists(attack_hitbox)) {
    instance_destroy(attack_hitbox);
}