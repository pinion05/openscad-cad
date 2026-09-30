/* 04. 리어 서스펜션 — 더블 위시본 + 코일오버(후방 경사) + 너클/브레이크 */
include <../params.scad>
include <../lib.scad>

module part_susp_rear() {
    ay = -axle_y;
    for (s = [-1, 1]) {
        /* 로어 위시본 */
        for (dy = [-lwr_dy, lwr_dy])
            translate([s*472, ay + dy, lwr_z]) rotate([0, s*90, 0])
                difference() {
                    cylinder(h = 64, d = bush_od, center = true, $fn = rod_fn);
                    cylinder(h = 68, d = 20,     center = true, $fn = rod_fn);
                }
        rod([s*472, ay - lwr_dy, lwr_z], [s*knk_x_r, ay, lwr_z], arm_od);
        rod([s*472, ay + lwr_dy, lwr_z], [s*knk_x_r, ay, lwr_z], arm_od);
        translate([s*knk_x_r, ay, lwr_z]) sphere(d = ball_od, $fn = rod_fn);

        /* 어퍼 위시본 (인보드 피벗 x=370) */
        for (dy = [-upr_dy, upr_dy])
            translate([s*370, ay + dy, upr_z]) rotate([0, s*90, 0])
                difference() {
                    cylinder(h = 52, d = 42, center = true, $fn = rod_fn);
                    cylinder(h = 56, d = 18, center = true, $fn = rod_fn);
                }
        rod([s*370, ay - upr_dy, upr_z], [s*knk_x_r, ay, upr_z], 30);
        rod([s*370, ay + upr_dy, upr_z], [s*knk_x_r, ay, upr_z], 30);
        translate([s*knk_x_r, ay, upr_z]) sphere(d = 54, $fn = rod_fn);

        /* 너클 + 브레이크 */
        rod([s*knk_x_r, ay, knk_z0], [s*knk_x_r, ay, knk_z1], knk_od);
        translate([s*590, ay, 445]) rotate([0, s*90, 0])
            cylinder(h = 215, d = stub_od, $fn = rod_fn);              // x 590~805
        translate([s*(knk_x_r + 18), ay, 445]) rotate([0, s*90, 0])
            difference() {
                cylinder(h = 12, d = disc_r*2, $fn = 64);
                cylinder(h = 16, d = 120, center = true, $fn = 48);
            }
        translate([s*(knk_x_r + 30), ay, 445]) rotate([0, s*90, 0])
            cylinder(h = 18, d = 130, $fn = 48);
        translate([s*(knk_x_r + 16), ay + 130, 495])
            cube([36, 100, 130], center = true);

        /* 코일오버 (하단 = 로어암 앞레그 안장, 상단 = 리어 타워) */
        shock(mir(shock_bot_r, s), mir(shock_top_r, s));
        rod([s*536, -1105, 500], [s*536, -1105, 533], 24);
    }
}

part_susp_rear();
