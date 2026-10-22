varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vWorldPos;

uniform sampler2D u_NormalMap;
uniform vec3 u_LightPos;      
uniform float u_FacingDir;    
uniform float u_ShadowIntensity; // How dark the shadow is (e.g., 0.4 = 40% darker)

void main() {
    vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord);
    if (base_color.a == 0.0) discard;

    // 1. EXTRACT DIRECTION VECTORS FROM LAIGTER MAP
    vec4 normal_sample = texture2D(u_NormalMap, v_vTexcoord);
    vec3 normal = normal_sample.rgb * 2.0 - 1.0; 
    
    if (u_FacingDir < 0.0) {
        normal.x = -normal.x; 
    }
    normal = normalize(normal);

    // 2. GET DIRECTION TO LIGHT
    vec3 light_dir = vec3(u_LightPos.xy - v_vWorldPos.xy, u_LightPos.z);
    light_dir = normalize(light_dir);

    // 3. HARD THRESHOLD (The Pixel-Art Secret)
    float dot_product = dot(normal, light_dir);
    
    // If the dot product is below 0.1, the pixel is facing away from the light.
    // We instantly apply a shadow multiplier, otherwise it stays full brightness (1.0).
    float shadow_mask = (dot_product < 0.1) ? (1.0 - u_ShadowIntensity) : 1.0;

    // 4. APPLY ONLY THE SHADOW TO THE ORIGINAL SPRITE COLORS
    // This keeps your original hand-picked pixel palette perfectly intact!
    vec3 final_color = base_color.rgb * shadow_mask;
    
    gl_FragColor = v_vColour * vec4(final_color, base_color.a);
}