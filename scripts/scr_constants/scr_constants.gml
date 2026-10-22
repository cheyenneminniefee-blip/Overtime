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