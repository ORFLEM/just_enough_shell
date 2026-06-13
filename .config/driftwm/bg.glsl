// Dot grid background — evenly spaced dots that scroll with the canvas.
// Zoom is handled externally (RescaleRenderElement) — shader works in canvas space.
// Edit colors, spacing, and dot size directly here.
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform vec2 u_camera;

const float DOT_SPACING = 80.0;
const float DOT_RADIUS  = 2.5;   // радиус белого ядра
const float GAP         = 0.0;   // зазор между ядром и кольцом
const float RING_WIDTH  = 1.5;   // толщина кольца
const float AA          = 0.8;   // ширина антиалиасинга

// Цвета
const vec3  DOT_COL  = vec3(1.0);         // белое ядро
const float DOT_A    = 0.95;
const vec3  RING_COL = vec3(0.0);         // чёрное кольцо
const float RING_A   = 0.75;

void main() {
    vec2 screen_px  = v_coords * size;
    vec2 canvas_pos = screen_px + mod(u_camera, DOT_SPACING);

    vec2 grid = mod(canvas_pos, DOT_SPACING);
    // расстояние от центра ближайшей точки сетки
    vec2 d2   = grid - vec2(DOT_SPACING * 0.5);
    // поправка: ищем ближайший узел, не центр ячейки
    d2 = mod(canvas_pos + DOT_SPACING * 0.5, DOT_SPACING) - vec2(DOT_SPACING * 0.5);
    float d = length(d2);

    // Белое ядро
    float core = 1.0 - smoothstep(DOT_RADIUS - AA, DOT_RADIUS + AA, d);

    // Кольцо: от (DOT_RADIUS + GAP) до (DOT_RADIUS + GAP + RING_WIDTH)
    float r_inner = DOT_RADIUS + GAP;
    float r_outer = r_inner + RING_WIDTH;
    float ring = smoothstep(r_inner - AA, r_inner + AA, d)
               * (1.0 - smoothstep(r_outer - AA, r_outer + AA, d));

    // Лёгкое внешнее свечение кольца (помогает на пёстром фоне)
    float glow = (1.0 - smoothstep(r_outer, r_outer + 3.0, d)) * 0.12;

    // Компоузим: сначала glow, потом ring, потом core
    vec4 col = vec4(0.0);
    col = mix(col, vec4(RING_COL, RING_A * 0.4), glow);
    col = mix(col, vec4(RING_COL, RING_A),        ring  * (1.0 - col.a));
    col = mix(col, vec4(DOT_COL,  DOT_A),         core  * (1.0 - col.a * 0.3));

    // Альфа-блендинг итоговый
    gl_FragColor = vec4(col.rgb, col.a * max(core, ring + glow));
}
