/// obj_enemy_melee_hitbox — enemy melee damage dealer
damage = 1;             // Attack scripts can override
owner = noone;          // The enemy that swung — assigned by the attack scripts
unblockable = false;    // PRD 6.2/7.2: HEAVY-type attacks go through guard
                        // wholly — the heavy script sets this true
hit_counted = false;    // block-streak counted once per swing, not per overlap step
                        // (the collision event fires every step the masks touch);
                        // fresh instance per swing, so this resets with it