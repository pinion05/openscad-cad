/* 03. 프런트 서스펜션 — 더블 위시본 + 코일오버 + 너클/브레이크 + 스티어링 랙
   X축 실린더는 항상 rotate([0, s*90, 0]) — s=−1에서 아웃보드로 뻗게 */
include <../params.scad>
include <../lib.scad>

module part_susp_front() {
    ay = axle_y;
    for (s = [-1, 1]) {
        /* 로어 위시본: 중공 부싱 2 + 볼조인트 */
        for (dy = [-lwr_dy, lwr_dy])
            translate([s*472, ay + dy, lwr_z]) rotate([0, s*90, 0])
                difference() {
                    cylinder(h = 64, d = bush_od, center = true, $fn = rod_fn);
                    cylinder(h = 68, d = 20,     center = true, $fn = rod_fn);
                }
        rod([s*472, ay - lwr_dy, lwr_z], [s*knk_x_f, ay, lwr_z], arm_od);
        rod([s*472, ay + lwr_dy, lwr_z], [s*knk_x_f, ay, lwr_z], arm_od);
        translate([s*knk_x_f, ay, lwr_z]) sphere(d = ball_od, $fn = rod_fn);

        /* 어퍼 위시본 (인보드 피벗 x=370) */
        for (dy = [-upr_dy, upr_dy])
            translate([s*370, ay + dy, upr_z]) rotate([0, s*90, 0])
                difference() {
                    cylinder(h = 52, d = 42, center = true, $fn = rod_fn);
                    cylinder(h = 56, d = 18, center = true, $fn = rod_fn);
                }
        rod([s*370, ay - upr_dy, upr_z], [s*knk_x_f, ay, upr_z], 30);
        rod([s*370, ay + upr_dy, upr_z], [s*knk_x_f, ay, upr_z], 30);
        translate([s*knk_x_f, ay, upr_z]) sphere(d = 54, $fn = rod_fn);

        /* 너클: 수직 튜브 + 허브 스터브(아웃보드) + 디스크/햇/캘리퍼 */
        rod([s*knk_x_f, ay, knk_z0], [s*knk_x_f, ay, knk_z1], knk_od);
        translate([s*610, ay, 445]) rotate([0, s*90, 0])
            cylinder(h = 235, d = stub_od, $fn = rod_fn);
        translate([s*(knk_x_f + 18), ay, 445]) rotate([0, s*90, 0])
            difference() {
                cylinder(h = 12, d = disc_r*2, $fn = 64);
                cylinder(h = 16, d = 120, center = true, $fn = 48);
            }
        translate([s*(knk_x_f + 30), ay, 445]) rotate([0, s*90, 0])
            cylinder(h = 18, d = 130, $fn = 48);                       // 허브 햇
        translate([s*(knk_x_f + 16), ay + 130, 495])
            cube([36, 100, 130], center = true);                       // 캘리퍼

        /* 스티어링: 너클 암 + 타이로드 */
        rod([s*knk_x_f, ay - 40, 470], [s*600, ay - 35, 500], 24);
        translate([s*600, ay - 35, 500]) sphere(d = 44, $fn = rod_fn);
        rod([s*370, rack_y + 38, rack_z], [s*600, ay - 35, 500], 30);

        /* 코일오버 (하단 = 로어암 프런트 레그 안장) */
        shock(mir(shock_bot_f, s), mir(shock_top_f, s));
        rod([s*554, 1198, 500], [s*554, 1198, 528], 24);
    }
    /* 스티어링 랙 (액슬 뒤) */
    translate([0, rack_y, rack_z]) rotate([0, 90, 0])
        cylinder(h = rack_hw*2, d = rack_od, center = true, $fn = rod_fn);
    for (s = [-1, 1])
        translate([s*370, rack_y, rack_z]) rotate([0, 90, 0])
            cylinder(h = 64, d = 70, center = true, $fn = rod_fn);
}

part_susp_front();
