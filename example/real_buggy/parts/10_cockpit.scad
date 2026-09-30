/* 10. 코크핏 — 버킷시트 2(볼스터+백레스트+헤드레스트+하니스슬롯)·대시·
   스티어링(컬럼+3스포크 휠)·페달박스·시프트 레버·파킹 브레이크 */
include <../params.scad>
include <../lib.scad>

col_a = [-330, 60, 770];     // 스티어링 휠 허브(축 상 50)
col_b = [-360, 961, 550];    // 랙 방향 컬럼 끝

module seat(x) {
    for (dx = [-120, 120], dy = [-30, -200]) {
        translate([x + dx, dy, z0])
            linear_extrude(14) offset(r = 6) square([50, 50], center = true);
        rod([x + dx, dy, 427], [x + dx, dy, 500], 28);
    }
    translate([x, -135, 540]) cube([380, 190, 90], center = true);          // 쿠션
    for (sb = [-1, 1])
        translate([x + sb*165, -135, 585]) cube([50, 190, 90], center = true);  // 사이드 볼스터
    hull() {                                                                  // 백레스트(11° 레이크)
        translate([x, -245,  640]) rotate([-11, 0, 0]) cube([340, 90, 40], center = true);
        translate([x, -310, 1040]) rotate([-11, 0, 0]) cube([340, 90, 40], center = true);
    }
    translate([x, -315, 1110]) cube([260, 110, 120], center = true);         // 헤드레스트
    for (hb = [-1, 1])
        translate([x + hb*90, -318, 1060]) cube([50, 30, 20], center = true); // 하니스 슬롯
}

module part_cockpit() {
    seat(330);  seat(-330);

    /* 대시: 상단 패드 + 페이스(컬럼 리세스 컷) + 계기 화면 */
    translate([0, 200, 915]) cube([1040, 160, 30], center = true);
    difference() {
        translate([0, 140, 775]) cube([1040, 40, 310], center = true);
        orient(col_a, col_b) cylinder(r = 210, h = 900, $fn = 48);
    }
    translate([0, 122, 860]) cube([320, 30, 140], center = true);

    /* 스티어링: 컬럼 + U조인트 + 휠(테 + 3스포크 + 허브) */
    orient(col_a, col_b) {
        cylinder(d = 38, h = 900, $fn = rod_fn);
        translate([0, 0, 790]) cube([70, 70, 60], center = true);
    }
    orient(col_a, col_b) translate([0, 0, 50]) {
        rotate_extrude($fn = 96) translate([170, 0]) circle(d = 36, $fn = 20);
        for (a = [90, 210, 330])
            rotate([0, 0, a]) translate([85, 0, 0]) cube([170, 34, 16], center = true);
        cylinder(d = 70, h = 40, center = true, $fn = rod_fn);
    }

    /* 페달 박스 + 페달 3 */
    translate([-310, 400, 500]) cube([180, 60, 160], center = true);
    for (px = [-370, -310, -250])
        translate([px, 350, 620]) rotate([-25, 0, 0]) cube([36, 130, 10], center = true);

    /* 시프트 레버 + 노브 (프롭 터널 위) / 파킹 브레이크 */
    rod([0, -100, 505], [35, -55, 668], 22);
    translate([38, -52, 690]) sphere(d = 90, $fn = rod_fn);
    translate([112, -40, 520]) cube([40, 120, 60], center = true);
}

part_cockpit();
