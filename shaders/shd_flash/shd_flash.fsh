// shd_flash — fragment
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_flash;

void main() {
    vec4 _base = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
    gl_FragColor = vec4(mix(_base.rgb, vec3(1.0), u_flash), _base.a);
}