#version 440

layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
} ubuf;

layout(binding=1) uniform sampler2D source;

// ------------------------------------------------------------
// Шум для фона (как в Aurora)
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// Фон: серый градиент из шума
// ------------------------------------------------------------
float grayBackground(vec2 uv, float t) {
    float n1 = noise(uv * 2.5 + vec2(t * 0.02, t * 0.01));
    float n2 = noise(uv * 5.0 - vec2(t * 0.015, t * 0.025));
    float n3 = noise(uv * 10.0 + vec2(t * 0.03, -t * 0.02));
    float n = (n1 * 0.5 + n2 * 0.3 + n3 * 0.2);
    // монохромная яркость: примерно от 0.1 до 0.6
    return 0.15 + n * 0.55;
}

// ------------------------------------------------------------
// Капли
// ------------------------------------------------------------
// Набор позиций (нормированные UV) и времён падения
const vec2 dropPositions[8] = vec2[](
    vec2(0.25, 0.35),
    vec2(0.65, 0.70),
    vec2(0.80, 0.20),
    vec2(0.40, 0.55),
    vec2(0.10, 0.85),
    vec2(0.55, 0.45),
    vec2(0.90, 0.60),
    vec2(0.30, 0.15)
);

// Периоды для каждой капли (разные)
const float periods[8] = float[](2.7, 3.3, 2.1, 3.8, 2.5, 4.0, 2.9, 3.5);

float dropWave(vec2 uv, vec2 center, float timeSinceDrop) {
    // время с начала падения (секунды)
    float age = timeSinceDrop;
    if (age < 0.0 || age > 5.0) return 0.0; // капля умерла

    float dist = length(uv - center);
    // радиус волны растёт, но замедляется
    float radius = age * 0.25;
    // затухание по времени
    float life = 1.0 - smoothstep(0.0, 4.0, age);
    // форма кольца
    float ring = sin((dist - radius) * 20.0) * exp(-dist * 3.0);
    // сглаживаем, чтобы не было острых пиков
    ring *= smoothstep(radius + 0.3, radius, dist) * smoothstep(radius - 0.3, radius, dist);
    return ring * life * 0.4;
}

// ------------------------------------------------------------
// Главная функция
// ------------------------------------------------------------
void main() {
    vec2 uv = qt_TexCoord0;
    float t = ubuf.time;

    // Фон
    float gray = grayBackground(uv, t);
    vec3 bgColor = vec3(gray); // серый

    // Акцентный цвет волн (можно заменить на любой)
    vec3 accent = vec3(0.45, 0.35, 0.95); // насыщенный сине-фиолетовый

    // Суммируем волны от всех капель
    float waves = 0.0;
    for (int i = 0; i < 8; i++) {
        // время сброса для цикличности
        float cycleTime = mod(t + float(i) * 0.7, periods[i]);
        // капля активна только первые 4 секунды цикла
        float localTime = cycleTime < 4.0 ? cycleTime : -1.0;
        waves += dropWave(uv, dropPositions[i], localTime);
    }

    // Смешиваем фон с акцентными волнами
    vec3 color = mix(bgColor, accent, clamp(waves, 0.0, 0.7));

    // Лёгкая виньетка
    vec2 vig = uv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vig, vig) * 0.35;
    color *= vignette;

    fragColor = vec4(color, 1.0) * ubuf.qt_Opacity;
}
