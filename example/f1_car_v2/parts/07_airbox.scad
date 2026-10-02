// 07 에어박스 — 롤 hoops 험프 + 타원 인테이크 림
include <../params.scad>
use <../lib.scad>

module airbox() {
    difference() {
        loftr(ABX_SEC);
        // 인테이크 컵 (링 뒤 오목 음영)
        translate(ABX_RING_C) rotate([-90, 0, 0]) scale([1, 0.72, 1])
            cylinder(r = 7.0, h = 12, center = true, $fn = 64);
    }
    // 인테이크 림 — 축 Y 타원 토러스
    translate(ABX_RING_C) scale([1, 1, ABX_RING_SZ]) rotate([-90, 0, 0])
        rotate_extrude($fn = 64) translate([ABX_RING_R, 0]) circle(ABX_RING_T, $fn = 48);
}

airbox();
