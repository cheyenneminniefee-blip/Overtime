/// obj_ion_bolt — Ranger projectile (PRD 7.2, 6.2 ION type)
damage = 10;                 // PRD 7.2: ion bolt, 10
move_spd = 640 / 60;         // 640 px/s at 60 fps (PRD 11.1 — swept, AC35)
hspd = 0;
vspd = 0;                    // Linear flight — no gravity on ion bolts
owner = noone;               // The Ranger that fired it — parry stuns this
reflected = false;           // Set by a perfect parry; the bolt turns player-owned (PRD 5.4)
lifetime = 180;              // 3 s safety cleanup for bolts that never hit anything
image_speed = 0;
