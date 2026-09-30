/* 05. 프런트 휠 — 블록형 트레드 오프로드 타이어 + 딥디시 림 (타이어+림 일체 출력)
   로컬 축: 휠 축 = +Z (조립 시 ±X 회전 배치), 외경 110mm */
include <../params.scad>
include <../lib.scad>

/* 바퀴 공통 모듈 (tire_w = 타이어 폭) */
module wheel(tire_w) {
    w = tire_w;
    carcass_r = tire_carcass_r;
    bore_r    = tire_bore_r - rim_gap;      // 림-타이어 0.4mm 맞춤
    // ---- 타이어 카카스 (어깨 찬퍼) ----
    difference() {
        hull() {
            cylinder(r = carcass_r,     h = w - 7, center = true, $fn = wheel_fn);
            cylinder(r = carcass_r - 3.5, h = w - 1, center = true, $fn = wheel_fn);
        }
        translate([0, 0, -w]) cylinder(r = bore_r, h = 2*w, $fn = wheel_fn);
    }
    // ---- 블록 트레드 (3행, 가운데 행 1/2 피치 스태거) ----
    rows = w > 45 ? [-16, 0, 16] : [-13, 0, 13];
    for (rz = rows, i = [0 : tread_n - 1])
        rotate([0, 0, i*360/tread_n + (rz == 0 ? 180/tread_n : 0)])
            translate([carcass_r - 1.5 + tread_depth/2, 0, rz])
                cube([tread_depth + 3, tread_len, tread_w], center = true);
    // ---- 림 배럴 + 비드 링 ----
    barrel_len = w - 6;
    difference() {
        cylinder(r = bore_r, h = barrel_len, center = true, $fn = wheel_fn);
        cylinder(r = bore_r - rim_wall, h = barrel_len + 4, center = true, $fn = wheel_fn);
    }
    for (sz = [-1, 1])
        difference() {
            translate([0, 0, sz*(w/2 - bead_t/2 - 0.5)])
                cylinder(r = bore_r, h = bead_t, $fn = wheel_fn);
            translate([0, 0, sz*(w/2 - bead_t/2 - 0.5) - 2])
                cylinder(r = bore_r - rim_wall - 2.6, h = bead_t + 4, $fn = wheel_fn);
        }
    // ---- 허브 + 6스포크 (아웃보드 +z, 딥디시) ----
    translate([0, 0, w/2 - 12]) cylinder(r = hub_disc_r, h = 6, $fn = rod_fn);
    for (i = [0 : 5])
        rotate([0, 0, i*60])
            translate([23.5, 0, w/2 - 12.5])
                cube([15, 7, 5], center = true);
    translate([0, 0, w/2 - 9]) cylinder(r = 6, h = 3, $fn = rod_fn);  // 허브 캡
}

module part_wheel_front() { wheel(tire_w_f); }

part_wheel_front();
