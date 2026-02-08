shader_type canvas_item;
uniform float radius = 0.5;
uniform float softness = 0.5;
uniform float color_alpha = 0.5;

void fragment() {
    vec2 uv = SCREEN_UV - vec2(0.5);
    float vignette = smoothstep(radius, radius - softness, length(uv));
    COLOR = mix(vec4(0.0), vec4(0.0, 0.0, 0.0, 1.0), (1.0 - vignette) * color_alpha);
}