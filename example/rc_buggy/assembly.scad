/* =====================================================================
   전체 조립 — RC 오프로드 버기 1:10
   좌표계 그대로 각 부품을 배치 (바닥 z=0, 전진 +Y)
   ===================================================================== */
include <params.scad>
use <parts/01_chassis.scad>
use <parts/02_rollcage.scad>
use <parts/03_suspension_front.scad>
use <parts/04_suspension_rear.scad>
use <parts/05_wheel_front.scad>
use <parts/06_wheel_rear.scad>
use <parts/07_bonnet.scad>
use <parts/08_rear_body.scad>
use <parts/09_cockpit.scad>
use <parts/10_drivetrain.scad>
use <parts/11_bumper_front.scad>
use <parts/12_spoiler.scad>

// ---- 컬러 (렌더링용) ----
c_chassis = [0.72, 0.74, 0.78];
c_cage    = [0.85, 0.20, 0.15];
c_susp    = [0.22, 0.24, 0.28];
c_wheel   = [0.13, 0.13, 0.15];
c_body    = [0.92, 0.91, 0.88];
c_cockpit = [0.10, 0.10, 0.12];
c_engine  = [0.35, 0.38, 0.42];
c_bumper  = [0.20, 0.20, 0.25];

module assembly() {
    color(c_chassis) part_chassis();
    color(c_cage)    part_rollcage();
    color(c_susp)    part_susp_front();
    color(c_susp)    part_susp_rear();
    color(c_wheel)
        for (s = [-1, 1]) {
            translate([s*hub_f_x, axle_f_y, hub_z]) rotate([0, s*90, 0]) wheel(tire_w_f);
            translate([s*hub_r_x, axle_r_y, hub_z]) rotate([0, s*90, 0]) wheel(tire_w_r);
        }
    color(c_body)    part_bonnet();
    color(c_body)    part_rear_body();
    color(c_cockpit) part_cockpit();
    color(c_engine)  part_drivetrain();
    color(c_bumper)  part_bumper();
    color(c_cage)    part_spoiler();
}

assembly();
