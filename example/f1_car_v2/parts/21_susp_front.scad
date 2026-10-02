// 21 프런트 서스펜션 — 업라이트+디스크+스텁, 위시본 4본, 트랙로드, 푸시로드 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module susp_front()
for (s = [-1, 1]) {
    // 업라이트 (휠 인보드) + 브레이크 디스크 + 스텁 액슬
    rbox(s * 60.65, AXF_Y, 25, 48, 7.3, 12, 2.5);
    translate([s * 60, AXF_Y, WH_Z]) rotate([0, s * 90, 0])
        cylinder(r = DISC_R, h = 3, $fn = 96);
    translate([s * 60, AXF_Y, WH_Z]) rotate([0, s * 90, 0])
        cylinder(d = STUB_D, h = 11.8, $fn = 48);
    // 암 (픽업端은 노우즈 표면 0.3 여유)
    for (a = F_ARM) rod(mir(a[0], s), mir(a[1], s), ARM_OD);
    rod(mir(F_PUSH[0], s), mir(F_PUSH[1], s), 2.6);
}

susp_front();
