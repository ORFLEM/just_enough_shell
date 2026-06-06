#version 440

layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;         // единственный внешний параметр
} ubuf;

layout(binding=1) uniform sampler2D source;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    vec2 uv = qt_TexCoord0;

    // три слоя шума с независимым движением
    float t = ubuf.time * 0.03;
    float n1 = noise(uv * 3.0 + vec2(t, t * 0.7));
    float n2 = noise(uv * 5.0 - vec2(t * 0.8, t * 1.2));
    float n3 = noise(uv * 8.0 + vec2(t * 1.5, -t));

    float n = (n1 * 0.6 + n2 * 0.3 + n3 * 0.1);
    n = n * 0.8 + 0.2;

    // цвет через косинусную палитру, фаза зависит от n и времени
    float hueShift = ubuf.time * 0.02;
    vec3 col = 0.5 + 0.5 * cos(6.28318 * (n + hueShift + vec3(0.0, 0.33, 0.67)));

    // виньетка
    vec2 vig = uv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vig, vig) * 0.45;
    col *= vignette;

    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
