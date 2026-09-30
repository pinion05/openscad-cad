/* =====================================================================
   전체 조립 — 리얼 스케일 오프로드 버기 (1:1)
   좌표계 그대로 각 부품 배치 (바닥 z=0, 전진 +Y) | 스페어 타이어 = 06 인스턴스
   ===================================================================== */
include <params.scad>
use <lib.scad>
use <parts/01_frame.scad>
use <parts/02_rollcage.scad>
use <parts/03_suspension_front.scad>
use <parts/04_suspension_rear.scad>
use <parts/05_wheel_front.scad>
use <parts/06_wheel_rear.scad>
use <parts/07_bodywork.scad>
use <parts/08_bumper_front.scad>
use <parts/09_bumper_rear.scad>
use <parts/10_cockpit.scad>
use <parts/11_drivetrain.scad>
use <parts/12_lights.scad>

/* ---- 컬러 (렌더링용) ---- */
c_frame   = [0.62, 0.64, 0.68];   // 아연도금 강관
c_cage    = [0.16, 0.17, 0.19];   // 블랙 크로몰리
c_susp    = [0.25, 0.27, 0.30];
c_wheel   = [0.12, 0.12, 0.13];
c_body    = [0.85, 0.36, 0.10];   // 데저트 오렌지
c_cockpit = [0.10, 0.10, 0.12];
c_engine  = [0.45, 0.48, 0.53];
c_bumper  = [0.20, 0.21, 0.24];
c_light   = [0.92, 0.92, 0.80];

module assembly() {
    color(c_frame)   part_frame();
    color(c_cage)    part_rollcage();
    color(c_susp)    part_susp_front();
    color(c_susp)    part_susp_rear();
    color(c_wheel)
        for (s = [-1, 1]) {
            translate([s*hub_x,  axle_y, wheel_r]) rotate([0, s*90, 0]) wheel(tire_w_f);
            translate([s*hub_x, -axle_y, wheel_r]) rotate([0, s*90, 0]) wheel(tire_w_r);
        }
    color(c_wheel)   translate([0, -1420, 1048.4 + tire_w_r/2]) wheel(tire_w_r);  // 스페어
    color(c_body)    part_bodywork();
    color(c_bumper)  part_bumper_front();
    color(c_bumper)  part_bumper_rear();
    color(c_cockpit) part_cockpit();
    color(c_engine)  part_drivetrain();
    color(c_light)   part_lights();
}

assembly();
