// --- Camera Resolution Setup ---
cam_width = 1280;  // Change this to match your desired target resolution
cam_height = 720; // Change this to match your desired target resolution

target = obj_player; // Object to follow

// --- Tuning Variables (Adjust these to taste!) ---
follow_speed = 0.1;   // How fast the camera catches up to the player (0.01 = slow/loose, 0.5 = tight)
peek_speed = 0.04;    // How smoothly the camera shifts its gaze forward when moving
peek_max_dist = 80;   // The maximum distance (in pixels) the camera peeks ahead

// --- Internal Tracking ---
peek_offset_x = 0;

// Force GameMaker to activate views and assign our viewport size
view_enabled = true;
view_visible[0] = true;
camera_set_view_size(view_camera[0], cam_width, cam_height);