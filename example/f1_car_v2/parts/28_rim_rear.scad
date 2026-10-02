// 28 리어 림 — 구조는 프런트 동일, 반폭 17.4
include <../params.scad>
use <../lib.scad>

module rim_rear() {
    rotate([0, 90, 0]) difference() {
        cylinder(r = RIM_R, h = 2 * RIM_LR, center = true, $fn = 96);
        cylinder(r = RIM_R - RIM_T, h = 2 * RIM_LR + 2, center = true, $fn = 96);
    }
    translate([RIM_LR - 0.8, 0, 0]) rotate([0, 90, 0]) ann(19.5, RIM_R, 1.6);
    translate([RIM_LR - 0.9, 0, 0]) rotate([0, 90, 0])
        cylinder(r = 7.5, h = 1.8, center = true, $fn = 48);
    for (i = [0:9]) rotate([i * 36, 0, 0])
        translate([RIM_LR - 1.6, 8.2, -1.5]) cube([1.5, 14, 3]);
    translate([RIM_LR + 0.9, 0, 0]) rotate([0, 90, 0])
        cylinder(r = 4.2, h = 2, center = true, $fn = 6);
    translate([-(RIM_LR - 1.1), 0, 0]) rotate([0, 90, 0]) ann(HUB_BORE / 2, 9.5, 3.4);
}

rim_rear();
