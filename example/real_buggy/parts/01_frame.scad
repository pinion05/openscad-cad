/* 01. 공간 튜브 프레임 — 사이드 레일·크로스멤버·플로어(디프 터널)·스키드·
   아암 피벗 브래킷(로어판+어퍼 빔)·쇼크 타워(슬롯 컷) */
include <../params.scad>
include <../lib.scad>

module part_frame() {
    /* ---- 사이드 레일 (저/중) ---- */
    for (s = [-1, 1]) {
        rod([s*rail_x,  1560, rail_z], [s*rail_x, -1560, rail_z], rail_od);
        rod([s*rail_x,   300, mid_z ], [s*rail_x,  -350, mid_z ], tube_sub);
    }
    /* ---- 크로스멤버 ---- */
    for (y = cross_y)
        rod([rail_x, y, rail_z], [-rail_x, y, rail_z], rail_od);

    /* ---- 플로어 (전후 디프 터널 컷) ---- */
    difference() {
        translate([0, 0, floor_z0])
            linear_extrude(floor_t)
                offset(r = 3) offset(delta = -3)
                    polygon([
                        [-590, -1700], [590, -1700], [590, -1500], [595, -1500],
                        [595, 1560], [-595, 1560], [-595, -1500], [-590, -1500],
                    ]);
        for (f = [1, -1])
            translate([0, f*axle_y, floor_z0 + floor_t/2])
                cube([240, 210, floor_t + 8], center = true);   // 디프 터널(노즈 포함)
    }

    /* ---- 하부 스키드 (디프 회피 — 액슬 직전까지) ---- */
    for (sy = [1, -1])
        translate([0, sy*670, 350]) cube([skid_hw*2, 740, skid_t], center = true);

    /* ---- 위시본 피벗: 로어 판(x 420~480) + 어퍼 인보드 빔(x 370) ---- */
    for (s = [-1, 1], f = [1, -1]) {
        ay = f * axle_y;
        for (py = [ay - 63, ay + 63])                    // 로어 판 2 (부싱과 3mm)
            translate([s*440, py, lwr_z]) cube([60, 14, 100], center = true);
        rod([s*370, ay - 43, upr_z], [s*370, ay + 43, upr_z], tube_sub);  // 어퍼 빔(판 사이)
        for (dy = [-1, 1]) {                             // 빔 → 크로스멤버 포스트
            rod([s*370, ay + dy*43, upr_z], [s*370, ay + dy*138, 392], tube_sub);
        }
        for (py = [ay - 37, ay + 37])                    // 어퍼 판 2 (빔에 용접)
            translate([s*370, py, upr_z]) cube([80, 12, 84], center = true);
    }

    /* ---- 쇼크 타워 (슬롯 컷 — 쇼크/스프링 통과) ---- */
    for (s = [-1, 1]) {
        difference() {                                    // 프런트 (y 990~1004)
            translate([s*440, 950, 837.5]) cube([120, 14, 475], center = true);
            orient(mir(shock_top_f, s), mir(shock_bot_f, s)) cylinder(r = 82, h = 760, $fn = 48);
        }
        rod([s*440, 950, 600], [s*556, 950, 392], tube_sub);      // 하단 브레이스
        rod([s*440, 950, 940], [s*548, 950, 620], tube_sub);      // 상단 브레이스(후드 하방)
        difference() {                                    // 리어 (전경사 쇼크, y-1035)
            translate([s*450, -1035, 797.5]) cube([100, 14, 395], center = true);
            orient(mir(shock_top_r, s), mir(shock_bot_r, s)) cylinder(r = 82, h = 560, $fn = 48);
        }
        rod([s*420, -1030, 600], [s*556, -965, 404], tube_sub);
    }
}

part_frame();
