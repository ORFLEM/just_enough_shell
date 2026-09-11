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

void main() {
    vec2 px = qt_TexCoord0 * resolution;
    float x = px.x;
    float y = resolution.y - px.y;   // 0 снизу, H сверху
    float H = resolution.y;
    float t = time * evolutionSpeed * 60.0;

    float n  = perlin2D(vec2(x * 0.008 + t * 0.12, t * 0.07));
    float n2 = perlin2D(vec2(x * 0.013 - t * 0.09 + 40.0, t * 0.05));

    float c1 = y - (H * 0.55 + H * 0.22 * n);
    float c2 = y - (H * 0.68 + H * 0.18 * n2);

    float vert = smoothstep(H * 0.10, H * 0.45, y) * smoothstep(H, H * 0.60, y);

    vec3 col = dark.rgb;
    col += accent.rgb * exp(-abs(c1) / (H * 0.09)) * vert * 0.85;
    col += mid.rgb    * exp(-abs(c2) / (H * 0.07)) * vert * 0.5;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
