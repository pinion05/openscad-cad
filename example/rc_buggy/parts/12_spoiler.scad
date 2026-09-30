/* 12. 리어 스포일러 — 리어 패널 위 스트럿 2개 + 윙(엔드플레이트 포함) */
include <../params.scad>
include <../lib.scad>

module part_spoiler() {
    // 스트럿 (리어 패널/쇼크 타워 브리지와 무간섭, 패널 상면 위 클리어런스)
    for (s = [-1, 1]) rod([s*40, -163, 96.8], [s*40, -184, 116.5], 7);
    // 윙 본체 (리딩엣지가 약간 높은 공력 각도, 전장 한계 y≥-200 준수)
    hull() {
        translate([0, -167, 121.5]) cube([140, 8,  3.2], center = true);  // 리딩엣지
        translate([0, -184, 118.8]) cube([140, 30, 3.2], center = true);  // 트레일링엣지
    }
    // 엔드플레이트
    for (s = [-1, 1]) translate([s*68.5, -184, 0]) plate(3, 42, 103, 129, r = 2);
}

part_spoiler();
