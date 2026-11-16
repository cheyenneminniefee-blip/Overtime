/// obj_grenade — lobbed explosive (Grenadier now, player Photon Grenade later)
// PRD 5.6 / 6.3 / 6.7: 30 dmg EXPLOSIVE, 72 px blast, friendly fire ON,
// 0.5 restitution bounces, fuse 1.1 s from throw, sympathetic detonation.
damage = 30;
blast_radius = 72;
grv = 0.35;                  // Matches the shared enemy/player gravity
fuse = 66;                   // 1.1 s from throw at 60 fps (PRD 5.6)
bounce = 0.5;                // Restitution on solid contact (PRD 5.6)
hspd = 0;
vspd = 0;
owner = noone;               // Who threw it — excluded from its own blast
thrown_by_player = false;    // Player grenades stay live during a Time Freeze (PRD 5.2)
image_speed = 0;
