#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float patternScale;
    float evolutionSpeed;
    vec2 resolution;
    vec4 accent;
    vec4 dark;
    vec4 mid;
};

vec2 hash2(vec2 p) {
    ivec2 q = ivec2(ivec2(p));
    q *= ivec2(1597334673u, 3812015801u);
    q = (q.x ^ q.y) * ivec2(1597334673u, 3812015801u);
    return vec2(q) * (1.0/float(0xffffffffu)) * 2.0 - 1.0;
}

float perlin2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    vec2 ga = hash2(i + vec2(0.0, 0.0));
    vec2 gb = hash2(i + vec2(1.0, 0.0));
    vec2 gc = hash2(i + vec2(0.0, 1.0));
    vec2 gd = hash2(i + vec2(1.0, 1.0));
    float va = dot(ga, f - vec2(0.0, 0.0));
    float vb = dot(gb, f - vec2(1.0, 0.0));
    float vc = dot(gc, f - vec2(0.0, 1.0));
    float vd = dot(gd, f - vec2(1.0, 1.0));
    return mix(mix(va, vb, u.x), mix(vc, vd, u.x), u.y) * 0.5 + 0.5;
}
// пролог + хелперы как в aurora.frag

void main() {
    vec2 px = qt_TexCoord0 * resolution;
    float x = px.x / resolution.x;       // 0..1 поперёк
    float y = resolution.y - px.y;
    float H = resolution.y;
    float t = time * evolutionSpeed * 60.0;

    vec3 col = dark.rgb;
    for (int i = 0; i < 15; i++) {
        float fi = float(i);
        float base = H * (0.18 + fi * 0.16);
        float yy = base
            + H * 0.05 * sin(x * 6.0 + t * (0.6 + fi * 0.13) + fi * 1.7)
            + H * 0.03 * sin(x * 11.0 - t * 0.4 + fi);
        float line = smoothstep(2.0, 0.8, abs(y - yy));   // толщина ~2px
        float fade = smoothstep(0.0, 0.2, x) * smoothstep(1.0, 0.8, x);
        col = mix(col, mix(mid.rgb, accent.rgb, fi / 4.0), line * 0.85 * fade);
    }

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
