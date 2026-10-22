/// obj_parallax_bg — infinite parallax background controller
// Place ONE instance per room, on a layer BELOW all tile/instance layers.

// Move self to the room's dedicated background layer (must be an instance layer)
var _ly = layer_get_id("background");
if (_ly != -1) layer_add_instance(_ly, id);

// --- LAYERS (direct sprite references — checked at compile time) ---
// Ordered CLOSEST -> FURTHEST, matching parallax_factors below.
// For other variants, override the whole array in Instance Creation Code:
//   bg_sprites = [spr_desert_below_1, spr_desert_below_2, spr_desert_below_3];
bg_sprites = [spr_desert_above_1, spr_desert_above_2, spr_desert_above_3];

// --- TUNING (read once, on first Draw) ---
// Index 0 pairs with bg_sprites[0] (the closest layer).
parallax_factors = [0.70, 0.40, 0.15];

// Vertical scroll factors ([] = auto-derive from the horizontal factors).
// Or exact values to pin the sky vertically: [0.35, 0.20, 0]
vert_factors     = [];
vert_factor_mult = 0.5;

y_offset = 0;             // nudge the whole stack down (+) / up (-), pixels

// --- INTERNALS ---
layers = [];              // built on first Draw (see scr_parallax_build)
_built = false;