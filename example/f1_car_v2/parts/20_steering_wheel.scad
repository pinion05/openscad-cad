// 20 스티어링 휠 — 틸트 플레이트 + 그립 + 스티어링 컬럼
include <../params.scad>
use <../lib.scad>

module steering_wheel() {
    translate(SW_C) rotate([SW_TILT, 0, 0]) {
        rotate([90, 0, 0]) linear_extrude(2.2, center = true)
            polygon(rrpts(17, 9, 2));                        // 림 플레이트
        for (s = [-1, 1]) translate([s * 8.2, 0, 0])
            cylinder(r = 1.8, h = 9, center = true, $fn = 24);  // 그립
    }
    rod([0, 41.5, 47.2], [0, 52, 32.2], 4, 32);   // 컬럼 → 콕핏 트러프 바닥
}

steering_wheel();
