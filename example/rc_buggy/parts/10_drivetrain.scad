/* 10. 파워트레인 — 리어 장착 엔진(블록+헤드+핀+머플러+에어클리너) + 프런트 라디에이터 + 냉각 호스 */
include <../params.scad>
include <../lib.scad>

module part_drivetrain() {
    // ---- 엔진 블록 (섀시 상면, 리어 마운트) ----
    translate([0, (eng_yf + eng_yr)/2, 0])
        plate(2*eng_hw, abs(eng_yr - eng_yf), z0, eng_top, r = 5);
    // 실린더 헤드 + 쿨링 핀
    translate([0, (head_yf + head_yr)/2, 0])
        plate(2*head_hw, abs(head_yr - head_yf), eng_top, head_top, r = 4);
    for (fz = [90.5, 94, 97.5])
        translate([0, (head_yf + head_yr)/2, fz]) cube([66, 30, 2], center = true);
    // ---- 배기: 헤더 → 파이프 → 머플러 (우측, 리어 어퍼 아암/타워 위로 통과) ----
    rod([30, -100, 92], [46, -110, 90], 9);
    rod([46, -110, 90], [50, -126, 86], 9);
    rod([50, -126, 86], [51, -138, 82], 12);
    // ---- 에어클리너 (헤드 후방 상단, 실린더형) ----
    translate([0, -113, head_top + gap]) {        // z 100.4~120.4
        cylinder(d = 22, h = 20, $fn = rod_fn);
        translate([0, 0, 20]) cylinder(d = 18, h = 2.5, $fn = rod_fn);
    }
    // ---- 라디에이터 (노즈 후방, 좁은 보닛보다 와이드) ----
    translate([0, (rad_y0 + rad_y1)/2, 0]) plate(2*rad_hw, rad_y1 - rad_y0, rad_z0, rad_z1, r = 4);
    for (s = [-1, 1])
        translate([s*(rad_hw - 4), (rad_y0 + rad_y1)/2, 0]) plate(8, 14, rad_z0 + 2, rad_z1 - 2, r = 3);
    // ---- 냉각 호스 (라디에이터 → 엔진, 보닛 하면/쇼크 타워 사이 코리더 루팅) ----
    for (s = [-1, 1]) {
        rod([s*39,   156, 80], [s*38.5, 148,  68],   6);   // 라디에이터 하강 엘보
        rod([s*38.5, 148, 68], [s*36,   -67.6, 63],  6);   // 사이드 롱 런
    }
}

part_drivetrain();
