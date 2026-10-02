// 26 프런트 림 — 배럴 셸 + 10스포크 페이스 + 허브 보어(Ø7) + 윙너트
include <../params.scad>
use <../lib.scad>

module rim_front() {
    // 배럴 (얇은 셸)
    rotate([0, 90, 0]) difference() {
        cylinder(r = RIM_R, h = 2 * RIM_LF, center = true, $fn = 96);
        cylinder(r = RIM_R - RIM_T, h = 2 * RIM_LF + 2, center = true, $fn = 96);
    }
    // 아웃보드 페이스: 링 + 허브 + 스포크 10
    translate([RIM_LF - 0.8, 0, 0]) rotate([0, 90, 0]) ann(19.5, RIM_R, 1.6);
    translate([RIM_LF - 0.9, 0, 0]) rotate([0, 90, 0])
        cylinder(r = 7.5, h = 1.8, center = true, $fn = 48);
    for (i = [0:9]) rotate([i * 36, 0, 0])
        translate([RIM_LF - 1.6, 8.2, -1.5]) cube([1.5, 14, 3]);
    // 윙너트 (헥스)
    translate([RIM_LF + 0.9, 0, 0]) rotate([0, 90, 0])
        cylinder(r = 4.2, h = 2, center = true, $fn = 6);
    // 인보드 허브 보스 — 보어 r3.5 (스텁과 방사 간극 0.4)
    translate([-(RIM_LF - 1.1), 0, 0]) rotate([0, 90, 0]) ann(HUB_BORE / 2, 9.5, 3.4);
}

rim_front();
