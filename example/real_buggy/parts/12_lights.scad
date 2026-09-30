/* 12. 라이트 — 루프 LED 라이트바(8포드) + A후프 미러 2 */
include <../params.scad>
include <../lib.scad>

module part_lights() {
    /* 루프 LED 바 (A후프 탑 크로스바 위 0.4) */
    for (s = [-1, 1])
        rod([s*350, 150, 1485], [s*350, 150, 1516], 24);
    translate([0, 150, 1516]) cube([940, 70, 70], center = true);
    for (xx = [-385 : 110 : 385])
        translate([xx, 108, 1516]) rotate([90, 0, 0])
            cylinder(d = 56, h = 55, center = true, $fn = 32);
    /* 미러 (A후프 튜브에 0.4 부유 클램프) */
    for (s = [-1, 1]) {
        rod([s*545, 430, 970], [s*545, 462, 992], 16);
        translate([s*545, 520, 1030]) rotate([0, 18, 0]) cube([26, 130, 80], center = true);
    }
}

part_lights();
