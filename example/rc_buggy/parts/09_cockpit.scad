/* 09. 콕핏 — 버킷 시트(볼스터/헤드레스트 포함) + 대시 패널 + 스티어링 휠 */
include <../params.scad>
include <../lib.scad>

module part_cockpit() {
    // ---- 시트 쿠션 + 사이드 볼스터 ----
    translate([0, 4, 0]) plate(88, 64, z0, z0 + 4, r = 8);
    for (s = [-1, 1]) translate([s*28, 4, 0]) plate(8, 64, z0 + 4, 76, r = 4);
    // ---- 틸트 백레스트 (하단은 냉각 호스 회피 위해 좁게) ----
    hull() {
        translate([0, -34, 69]) cube([60, 6, 10], center = true);
        translate([0, -50, 98]) cube([88, 6, 12], center = true);
    }
    // 헤드레스트 윙 좌우
    for (s = [-1, 1]) translate([s*34, -51, 0]) plate(20, 10, 90, 104, r = 5);
    // ---- 대시 패널 (보닛 하면 아래) ----
    translate([0, 59, 0]) plate(70, 4, 76, 86, r = 3);
    // ---- 스티어링: 컬럼 + 휠(3스포크) — 보닛 뒤 오픈 에어 공간에 배치 ----
    col_a = [0, 60, 70];      // 컬럼 하단
    col_b = [0, 47.5, 81.2];  // 컬럼 상단(허브 뒤)
    rod(col_a, col_b, 8);
    orient(col_a, [0, 46, 84]) {                       // 휠 평면 = 컬럼 축 수직
        rotate_extrude($fn = 48) translate([16, 0]) circle(d = 3.2, $fn = 16);
        for (a = [90, 210, 330])
            rotate([0, 0, a])
                translate([8, 0, 0]) cube([16, 3, 3], center = true);
        cylinder(d = 10, h = 6, center = true, $fn = rod_fn);
    }
}

part_cockpit();
