// Individual Light Properties (Can be changed per instance in the Room Editor)
light_color_r = 1.0;   // Red component (0.0 - 1.0)
light_color_g = 1.0;   // Green component
light_color_b = 1.0;   // Blue component (e.g., warm torchlight)

light_radius  = 50;   // How far the light reaches in pixels
light_height  = 40;    // Z-height (How far "off the screen" the light sits)

// Automatically pre-calculate the linear falloff based on your desired radius
// This saves our shader from doing heavy division math every frame!
light_falloff_linear = 1.0 / light_radius;