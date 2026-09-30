/* 08. 프런트 범퍼 — 튜브 후프(V암 2단) + 윈치 + LED 포드 2 */
include <../params.scad>
include <../lib.scad>

module part_bumper_front() {
    for (s = [-1, 1]) {
        foot(s*480, 1470, w = 70);
        rod([s*480, 1470, fz(bump_od)], [s*560, 1640, 560], bump_od);   // 상단 암
        rod([s*480, 1470, 470],         [s*560, 1640, 440], bump_od);   // 하단 암
        rod([s*560, 1640, 440],         [s*560, 1640, 560], bump_od);   // 엘보 수직
        /* LED 포드 */
        rod([s*330, 1640, 589], [s*330, 1640, 648], 24);
        translate([s*330, 1625, 700]) cube([130, 110, 90], center = true);
        translate([s*330, 1563, 700]) cube([90, 16, 70], center = true);   // 렌즈면
    }
    rod([-620, 1640, 560], [620, 1640, 560], bump_od);                     // 메인 크로스
    /* 윈치 (드럼 + 페어리드) */
    translate([0, 1595, 550]) rotate([0, 90, 0])
        cylinder(h = 170, d = 180, center = true, $fn = 48);
    translate([0, 1595, 660]) cube([240, 90, 20], center = true);          // 모터
    translate([0, 1652, 550]) cube([220, 24, 190], center = true);         // 페어리드
}

part_bumper_front();
