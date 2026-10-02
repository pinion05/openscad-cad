// 30 카메라/안테나 — T캠 + 사이드캠 + 안테나 ×2 + GPS 돔
include <../params.scad>
use <../lib.scad>

module cameras_antennas() {
    // T캠 (에어박스 링 탑)
    translate([0, TCAM_Y, TCAM_Z0 + 1.75]) rotate([90, 0, 0])
        linear_extrude(3, center = true) polygon(rrpts(13, 3.5, 1));
    for (s = [-1, 1]) translate([s * 4.5, TCAM_Y, TCAM_Z0 + 2.6]) rotate([90, 0, 0])
        cylinder(r = 2.2, h = 6, center = true, $fn = 32);
    // 사이드캠 (노우즈 측면 판)
    for (s = [-1, 1])
        loftr([[SIDECAM[0][0], s * 11.25, 1.4, 5, SIDECAM[0][1], 0.7],
               [SIDECAM[1][0], s * 11.30, 1.4, 4, SIDECAM[1][1], 0.7]]);
    // 안테나 ×2 (샤시 탑)
    for (a = ANT) rod([a[0], a[1], 45.35], [a[0], a[1], 52.5], 1.4, 16);
    // GPS 돔 (험프 탑)
    translate([0, -58, 73.4]) sphere(3, $fn = 40);
}

cameras_antennas();
