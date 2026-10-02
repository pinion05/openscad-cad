// 09 할로 — 타원 경로 튜브 후프 + 전방 필러 + 후방 다리
include <../params.scad>
use <../lib.scad>

module halo() {
    // 후프: 구 체인 휨 (평면도 타원 x=Rx sin, y=Cy+Ry cos / z 파형)
    pts = [for (i = [0:HALO_N]) let (t = i / HALO_N * 360)
        [HALO_RX * sin(t), HALO_CY + HALO_RY * cos(t),
         HALO_Z0 + HALO_ZA * cos(t)]];
    for (i = [0:HALO_N - 1]) hull() {
        translate(pts[i])     sphere(d = HALO_OD, $fn = 44);
        translate(pts[i + 1]) sphere(d = HALO_OD, $fn = 44);
    }
    // 전방 필러 (콕핏 전방 탑 → 후프 전방점, 표면 0.1 여유)
    rod([0, 64, 48.9], [0, 57.0, 69.1], 6.5, 40);
    // 후방 다리 ×2 (샤시 후미 탑 → 후프 후측점)
    for (s = [-1, 1]) rod([s * 13.5, -26.5, 53.95], [s * 12.95, -25.0, 65.2], 7, 40);
}

halo();
