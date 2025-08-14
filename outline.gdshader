shader_type spatial;

uniform vec4 outline_color = vec4(0.0,0.0,0.0,1.0);
uniform float outline_strength = 1.0;

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = dot(NORMAL, vec3(0, 0, 1)) * outline_strength;
}