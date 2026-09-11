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

#define DROPS 200
#define FAR_DROPS 30

float sdSeg(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

vec2 hash2(vec2 p) {
    ivec2 q = ivec2(ivec2(p));
    q *= ivec2(1597334673u, 3812015801u);
    q = (q.x ^ q.y) * ivec2(1597334673u, 3812015801u);
    return vec2(q) * (1.0/float(0xffffffffu)) * 2.0 - 1.0;
}

void main() {
    vec2 px = qt_TexCoord0 * resolution;
    float H = resolution.y;
    float W = resolution.x;
    float t = time * evolutionSpeed * 1000.0;

    vec3 col = dark.rgb;

    float slant = 0.18;                        // наклон линий
    vec2 dir = vec2(slant, 1.0);               // ось падения

    for (int i = 0; i < DROPS; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi + 1.0, fi * 2.7 + 3.0));
        bool far = i < FAR_DROPS;

        float len   = far ? 16.0 : 28.0;       // длина линии, px
        float wdt   = far ? 0.8 : 1.3;         // толщина, px
        float amp   = far ? 0.2 : 0.45;
        float speed = far ? 0.13 : 0.25;

        // голова: y идёт от -len до H+len строго вниз, x — вдоль наклона
        float yHead = -len + fract(h.x + t * speed) * (H + 2.0 * len);
        float xHead = fract(h.y * 7.0 + fi * 0.41) * (W + slant * (H + 2.0 * len))
                      - slant * (H + 2.0 * len) + slant * (yHead + len);
        vec2 head = vec2(xHead, yHead);
        vec2 tail = head - dir * len;

        // прямоугольная линия: постоянная толщина, чёткие края
        float d = sdSeg(px, tail, head);
        float line = 1.0 - smoothstep(wdt - 0.6, wdt, d);

        col += accent.rgb * line * amp;
    }

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
