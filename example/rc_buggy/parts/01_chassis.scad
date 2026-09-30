/* 01. 섀시 플레이트(하부) — 알루미늄 스타일 스켈레톤 플레이트 */
include <../params.scad>
include <../lib.scad>

module part_chassis() {
    difference() {
        // 메인 플레이트 (앞뒤 테이퍼 + 모서리 라운딩)
        translate([0, 0, chassis_z_bot])
            linear_extrude(chassis_t)
                offset(r = 3) offset(delta = -3)
                    polygon([
                        [-chassis_hw_r, chassis_y_r],
                        [ chassis_hw_r, chassis_y_r],
                        [ chassis_hw,  -chassis_taper_y],
                        [ chassis_hw,   chassis_taper_y],
                        [ chassis_hw_f, chassis_y_f],
                        [-chassis_hw_f, chassis_y_f],
                        [-chassis_hw,   chassis_taper_y],
                        [-chassis_hw,  -chassis_taper_y],
                    ]);
        // 경량화 오픈 (장착부를 피해 3개)
        for (yc = [-80, 0, 80])
            hull()
                for (dy = [-13, 13])
                    translate([0, yc + dy, chassis_z_bot - 1])
                        cylinder(r = 9, h = chassis_t + 2, $fn = 32);
    }
    // 측면 강화 레일 (센터 구간만 — 케이지 발판/바디 패널과 간섭 회피)
    for (s = [-1, 1])
        translate([s*(chassis_hw - rail_w/2), 0, chassis_z_top])
            cube([rail_w, 60, rail_h], center = true);
}

part_chassis();
