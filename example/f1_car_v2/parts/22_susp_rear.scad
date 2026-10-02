// 22 리어 서스펜션 — 업라이트+디스크+스텁, 위시본 4본, 풀로드, 드라이브샤프트 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module susp_rear()
for (s = [-1, 1]) {
    rbox(s * 52.2, AXR_Y, 25, 48, 6.4, 12, 2.5);
    translate([s * 50.5, AXR_Y, WH_Z]) rotate([0, s * 90, 0])
        cylinder(r = DISC_R, h = 3, $fn = 96);
    translate([s * 52, AXR_Y, WH_Z]) rotate([0, s * 90, 0])
        cylinder(d = STUB_D, h = 11.5, $fn = 48);
    for (a = R_ARM) rod(mir(a[0], s), mir(a[1], s), ARM_OD);
    rod(mir(R_PULL[0], s),  mir(R_PULL[1], s),  2.6);
    rod(mir(R_DRIVE[0], s), mir(R_DRIVE[1], s), 5.5, 32);   // 드라이브샤프트
}

susp_rear();
