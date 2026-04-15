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

// Количество контурных линий
#define CONTOUR_DENSITY 35.0
// Толщина линий
#define LINE_THICKNESS 0.027
// Количество октав шума
#define NOISE_OCTAVES 2

vec2 hash2(vec2 p) {
    uvec2 q = uvec2(ivec2(p));
    q *= uvec2(1597334673u, 3812015801u);
    q = (q.x ^ q.y) * uvec2(1597334673u, 3812015801u);
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

    return mix(mix(va, vb, u.x),
               mix(vc, vd, u.x), u.y) * 0.5 + 0.5;
}

float perlin4D(vec2 p, float w) {
    float n1 = perlin2D(p + vec2(w * 100.0, w * 73.0));
    float n2 = perlin2D(p + vec2(-w * 89.0, w * 137.0));
    float blend = fract(w);
    blend = blend * blend * (3.0 - 2.0 * blend);
    return mix(n1, n2, blend);
}

float fbm4D(vec2 p, float w) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < NOISE_OCTAVES; i++) {
        value += amplitude * perlin4D(p * frequency, w);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = qt_TexCoord0;
    uv.x *= resolution.x / resolution.y;

    float w = time * evolutionSpeed;
    vec2 p = uv * patternScale;
    float n = fbm4D(p, w);

    float contour_value = fract(n * CONTOUR_DENSITY);
    float line = step(contour_value, LINE_THICKNESS) + step(1.0 - LINE_THICKNESS, contour_value);
    line = clamp(line, 0.0, 1.0);

    // фон — dark, линии — accent с примесью mid
    vec3 bg = dark.rgb;
    vec3 fg = mix(mid.rgb, accent.rgb, 0.6);
    vec3 color = mix(bg, fg, line);

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
