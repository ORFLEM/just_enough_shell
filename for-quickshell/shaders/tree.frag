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

#define TIERS 8

float sdSeg(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// хаотичный ветер: сумма несоизмеримых синусов, амплитуда ~[-1, 1]
float wind(float p) {
    return sin(p) * 0.55
         + sin(p * 1.73 + 1.3) * 0.30
         + sin(p * 2.97 + 4.1) * 0.15;
}

void main() {
    vec2 px = qt_TexCoord0 * resolution;
    float t = time * evolutionSpeed * 60.0;

    float treeH = min(resolution.y * 0.5, 150.0);
    float halfW = treeH * 0.42;
    float cx = resolution.x * 0.5;
    float bottomY = resolution.y * 0.5 + treeH * 0.5;

    float ly = bottomY - px.y;
    float lx = px.x - cx;

    float tierH = treeH / float(TIERS);
    vec3 fillCol = accent.rgb * 0.9;
    vec3 lineCol = mix(accent.rgb, vec3(1.0), 0.5);

    vec3 col = dark.rgb;

    // ствол за листвой
    float trunkM = smoothstep(1.6, 1.1, abs(lx)) * step(ly, treeH * 1.02) * step(-10.0, ly);
    col = mix(col, lineCol, trunkM);

    // ярусы
    for (int k = 0; k < TIERS; k++) {
        float fk = float(k);
        float w = halfW * (1.0 - fk / (float(TIERS) + 0.5));
        float yk = (fk + 0.5) * tierH;
        float drop = tierH * 0.55;
        float th = tierH * 0.26;

        vec2 c = vec2(0.0, yk - th * 0.5);
        float dmin = 1e5;

        for (int s = 0; s < 2; s++) {
            float side = float(s) * 2.0 - 1.0;
            // свой хаотичный сигнал на каждую ветвь
            float bob = wind(t * 5.2 + fk * 0.3 + side * 1.71) * 2.5;
            dmin = min(dmin, sdSeg(vec2(lx, ly), c, vec2(side * w, yk + drop + bob)));
        }

        float band = smoothstep(th, th - 0.8, dmin);
        float outline = band * smoothstep(th - 2.6, th - 1.8, dmin);

        col = mix(col, fillCol, band * 0.85);
        col = mix(col, lineCol, outline * 0.9);
    }

    // звезда
    vec2 sp = vec2(lx, ly - treeH * 1.04);
    float sr = treeH * 0.06;
    float star = smoothstep(sr, sr * 0.7, abs(sp.x) + abs(sp.y));
    col = mix(col, lineCol, star);
    col += accent.rgb * exp(-length(sp) / (treeH * 0.09)) * 0.20 * (0.7 + 0.3 * sin(t * 2.0));

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
