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
    float x = px.x;
    float y = resolution.y - px.y;
    float H = resolution.y;
    float W = resolution.x;

    vec3 col = dark.rgb;

    // луна — правый верхний угол
    float md = length(vec2(x, y) - vec2(W * 0.78, H * 0.78));
    col += accent.rgb * (exp(-md * md / (W * 0.0018)) * 0.9
                       + exp(-md * md / (W * 0.0500)) * 0.12);

    // дюны снизу, ближние перекрывают дальние
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float base = H * (0.20 + fi * 0.18);
        float dune = base
            + H * 0.12 * perlin2D(vec2(x / W * (1.5 + fi * 0.8) + fi * 13.7, fi * 3.1))
            + H * 0.02 * sin(x / W * 7.0 + fi * 2.0);
        float m = smoothstep(2.0, 0.0, y - dune);
        vec3 dcol = mix(dark.rgb, mid.rgb, 0.3 + fi * 0.22);
        col = mix(col, dcol, m * (0.6 + fi * 0.1));
    }

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
