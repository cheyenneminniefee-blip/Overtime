/// scr_constants — level construction standards

#macro TILE_SIZE 32
#macro CHUNK_W   20
#macro CHUNK_H   23
#macro CHUNK_W_PX (CHUNK_W * TILE_SIZE)   // 640
#macro CHUNK_H_PX (CHUNK_H * TILE_SIZE)   // 736

// Door position standard (tile rows/cols inside a chunk)
#macro DOOR_ROW_TOP  18    // L/R doors occupy rows 18-20 at the outer columns
#macro DOOR_ROW_BOT  20
#macro DOOR_COL_A    9     // U/D doors occupy cols 9-10
#macro DOOR_COL_B    10
#macro CEIL_BOTTOM   1     // ceiling band = rows 0-1
#macro FLOOR_TOP     21    // floor band = rows 21-22
#macro FLOOR_BOTTOM  22

// Generation grid (rm_generated must be GEN_GRID_W*640 x GEN_GRID_H*736 px)
#macro GEN_GRID_W 16     // wider: primarily-horizontal levels
#macro GEN_GRID_H 8

// The ground line: rows 1-3 are the surface band, rows 4-6 the underground
#macro GROUND_LINE 4

// Fill art: slots of your tileset holding the earth body and its top edge.
// (Set both to the same index until you have a distinct top-edge tile.)
#macro ROCK_TILE_INDEX 1
#macro ROCK_TOP_TILE_INDEX 2

// Workshop chunk pitch: chunks are stored in rm_workshop separated by a
// 1-tile gutter so editor autotiling treats every chunk as an island.
// Generated rooms have NO gutters — stamped chunks still abut directly.
#macro GUTTER 1
#macro CHUNK_PITCH_W (CHUNK_W + GUTTER)               // 21 tiles
#macro CHUNK_PITCH_H (CHUNK_H + GUTTER)               // 24 tiles
#macro CHUNK_PITCH_W_PX (CHUNK_PITCH_W * TILE_SIZE)   // 672
#macro CHUNK_PITCH_H_PX (CHUNK_PITCH_H * TILE_SIZE)

// Time Freeze (PRD 5.2) — 5 s freeze, 30 s cooldown starting at activation.
// FROZEN_DAMAGE_MULT: frozen enemies take half damage (fractions kept).
// FREEZE_TINT: the icy tint on frozen enemies and the screen overlay —
// deliberately distinct from the white damage flash (PRD 12.3).
#macro FREEZE_DURATION 300
#macro FREEZE_COOLDOWN 1800
#macro FROZEN_DAMAGE_MULT 0.5
#macro FREEZE_TINT make_color_rgb(120, 190, 255)

// Phase Slash accent (PRD 12.1 HUD icon + cooldown sweep marker) — violet,
// distinct from the energy cyan and the freeze icy blue.
#macro PHASE_TINT make_color_rgb(190, 120, 255)

// Player HP (PRD 4.2: max 100) and the HUD segmentation (PRD 12.1: 25 HP per segment)
#macro HP_MAX 100
#macro HEALTH_SEGMENT 25

// --- HEAVY WEAPONS (PRD 5.8) ---
// The committed second slot (greatsword / spear / mace). Triggered by HOLDING
// the attack button: tap swings the Hard Light Sword on the press frame, and
// if the button is still down at the hold threshold the sword swing's
// remaining recovery is absorbed into the rooted, uninterruptible wind-up.
// PRD frame counts are 30 fps integers; this repo runs at 60 fps, so the 9 f
// threshold is doubled. Values are per-weapon here so spear/mace can slot in.
enum WEAPON { NONE, GREATSWORD, SPEAR, MACE }
#macro HEAVY_HOLD_THRESHOLD 30     // PRD 9 f @30fps -> 18 @60fps: the point of no return
#macro SWORD_DAMAGE 18             // Hard Light Sword baseline, type MELEE, 1x poise
#macro GREATSWORD_DAMAGE 40
#macro GREATSWORD_POISE 2.0        // 2x poise damage
#macro SPEAR_DAMAGE 35             // 35 (PRD 5.8): reach-and-pierce identity
#macro SPEAR_POISE 1.5             // 1.5x poise damage
#macro SPEAR_MAX_TARGETS 2         // PRD 5.8: the spear pierces up to 2 targets per swing
#macro HB_TARGETS_UNLIMITED -1     // hit cap sentinel (sword / greatsword hit everything in the arc)

// --- MACE + GROUND STUN WAVE (PRD 5.8) ---
// The mace is the slowest, heaviest heavy: an overhead strike plus a
// damage-free ground shockwave. PRD 30 fps integers doubled for this 60 fps
// repo. The wave fires on the mace animation's authored strike frame and
// stuns (never damages) every non-boss enemy in its zone.
#macro MACE_DAMAGE 60              // 60 (PRD 5.8): heaviest damage in the game
#macro MACE_POISE 3.0              // 3x poise damage
#macro MACE_STRIKE_FRAME 24        // authored mask onset of spr_player_attack_mace_hb
                                   // (verified by pixel scan: masks exist only on frames 24-25 of 37)
#macro MACE_STUN_DURATION 60       // wave stuns for 1.0 s @60fps (PRD 1.0 s)
#macro MACE_STUN_IMMUNITY 180      // then 3.0 s @60fps of wave-immunity, so a full
                                   // mace cycle can never stun-lock (PRD 3.0 s)
#macro MACE_WAVE_RANGE 100         // stun reach forward from the strike point
                                   // (past the melee 60 px and shield 80 px stop lines)
#macro MACE_WAVE_HEIGHT 80         // grounded band above/below the strike point