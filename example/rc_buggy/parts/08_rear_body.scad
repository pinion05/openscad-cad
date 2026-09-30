/* 08. 리어 바디 — 엔진 베이 사이드 패널 좌우 + 벤틸레이션 슬롯 리어 패널
   사이드 패널은 리어 어퍼 아암(y≈-130) 관통 회피 위해 y=-124까지 */
include <../params.scad>
include <../lib.scad>

module part_rear_body() {
    // 사이드 패널 (앞이 높고 뒤로 낮아지는 테이퍼, 두께 4)
    for (s = [-1, 1])
        hull() {
            translate([s*64, -63,  z0 + 21])    cube([4, 6, 42],   center = true);  // 프런트 에지 z0~96.4
            translate([s*64, -121, z0 + 13.25]) cube([4, 6, 26.5], center = true);  // 리어 에지   z0~80.9
        }
    // 리어 패널 (y -163~-159) + 벤틸 슬롯 3개
    difference() {
        translate([0, -161, 0]) plate(132, 4, z0, 92.4, r = 2);
        for (sz = [63, 72, 81])
            translate([0, -161, sz]) cube([36, 8, 6], center = true);
    }
}

part_rear_body();
