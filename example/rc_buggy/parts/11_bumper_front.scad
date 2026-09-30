/* 11. 프런트 범퍼 — 메인 크로스바 + 사이드 브레이스 + 접근각용 스키드 플레이트 */
include <../params.scad>
include <../lib.scad>

module part_bumper() {
    // 메인 크로스바 (od 12)
    rod([-70, 194, 70], [70, 194, 70], 12);
    // 사이드 브레이스 (섀시 노즈 위로 연결)
    for (s = [-1, 1]) rod([s*70, 194, 70], [s*56, 171, 59], 9);
    // 스키드 플레이트 (섀시 앞끝 → 범퍼 하단으로 상승)
    hull() {
        translate([0, 174.4, 52]) cube([84, 4, 4],  center = true);   // 섀시 노즈 직후
        translate([0, 192,   63]) cube([84, 4, 10], center = true);   // 범퍼 하단
    }
}

part_bumper();
