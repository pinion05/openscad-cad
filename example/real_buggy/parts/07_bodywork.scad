/* 07. 바디워크 — 후드(스쿕)·콜·노즈(그릴+헤드라이트)·사이드 포드·
   와이드 펜더 아치(전/후)·엔진 커버·테일 패널(길+테일램프) */
include <../params.scad>
include <../lib.scad>

/* 펜더 아치 쉘 — 축=X방향(휠축), R 492~506, 전후 팁은 수평면 5° 아래 */
module fender_arch(ay, x1) {
    cx = (fen_x0 + x1)/2;  wx = x1 - fen_x0;
    translate([cx, ay, 445]) rotate([0, 90, 0]) rotate([0, 0, 85])
        rotate_extrude(angle = 190, $fn = 64)
            translate([(fen_R0 + fen_R1)/2, 0])
                square([fen_R1 - fen_R0, wx], center = true);
}

/* 펜더 지지 스트럿 — 플로어 발판(t28) → 아치 팁 (타이어와 간극 확보 경로) */
module fen_strut(fy, ey) {
    foot(560, fy, w = 56, t = 28);
    rod([560, fy, 440], [652, ey, 401], 24);
}

module part_bodywork() {
    /* ---- 후드 (콜 → 전방 상승) + 에어 스쿕 ---- */
    hull() {
        translate([0,  340,  980]) cube([hood_hw*2, 20, 40], center = true);
        translate([0,  950, 1000]) cube([hood_hw*2, 20, 40], center = true);
    }
    difference() {
        hull() {
            translate([0, 510, 1030]) cube([300, 30, 40], center = true);
            translate([0, 870, 1080]) cube([300, 30, 30], center = true);
        }
        translate([0, 480, 1065]) cube([190, 80, 90], center = true);   // 스쿕 인렛
    }

    /* ---- 콜 패널 (대시 상단 덮개, 스티어링 휠 상단과 5mm) ---- */
    hull() {
        translate([0, 160, 992]) cube([1080, 20, 55], center = true);
        translate([0, 335, 990]) cube([1080, 20, 60], center = true);
    }

    /* ---- 노즈 패널 (그릴 오픈 + 헤드라이트 포드 ±450) ---- */
    difference() {
        hull() {
            translate([0, 1190, 1000]) cube([hood_hw*2, 20, 24], center = true);
            translate([0, 1550,  820]) cube([1120,      20, 24], center = true);
        }
        translate([0, 1425, 890]) cube([340, 280, 170], center = true);   // 그릴
    }
    for (s = [-1, 1]) {                                                  // 헤드라이트
        translate([s*450, 1460, 895]) rotate([90, 0, 0])
            cylinder(h = 130, d = 170, center = true, $fn = 48);
        translate([s*450, 1520, 895]) rotate([90, 0, 0])
            cylinder(h = 24, d = 122, center = true, $fn = 48);           // 렌즈
    }

    /* ---- 사이드 포드 (록가드) ---- */
    for (s = [-1, 1])
        hull() {
            translate([s*615,  275, 670]) cylinder(r = 20, h = 340, $fn = 32);
            translate([s*615, -325, 670]) cylinder(r = 20, h = 340, $fn = 32);
        }

    /* ---- 펜더 (전/후) + 스트럿 ---- */
    fender_arch( axle_y, fen_x1_f);
    fender_arch(-axle_y, fen_x1_r);
    fen_strut( 710,   669);   fen_strut( 1490,  1631);
    fen_strut(-710,  -669);   fen_strut(-1450, -1631);

    /* ---- 엔진 커버 (리어 데크, 시트 백레스트 회피 y-420부터) + 스커트 ---- */
    hull() {
        translate([0, -430,  982]) cube([cov_hw*2, 20, 55], center = true);
        translate([0, -950,  985]) cube([cov_hw*2, 20, 50], center = true);
    }
    for (s = [-1, 1])
        translate([s*(cov_hw - 10), -680, 830]) cube([20, 540, 250], center = true);

    /* ---- 테일 패널 (길 컷 + 테일램프) ---- */
    difference() {
        translate([0, tail_y, 660]) cube([tail_hw*2, 16, 480], center = true);
        for (zc = [470, 555, 640])
            translate([0, tail_y, zc]) cube([380, 24, 55], center = true);
    }
    for (s = [-1, 1])
        translate([s*190, tail_y - 18, 810]) cube([140, 36, 70], center = true);
}

part_bodywork();
