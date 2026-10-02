// F1 1:10 v2 — 조립 (30부품 + 휠 4)
include <params.scad>
use <lib.scad>
use <parts/01_floor.scad>
use <parts/02_diffuser.scad>
use <parts/03_floor_fences.scad>
use <parts/04_nose.scad>
use <parts/05_chassis.scad>
use <parts/06_engine_cover.scad>
use <parts/07_airbox.scad>
use <parts/08_sidepod.scad>
use <parts/09_halo.scad>
use <parts/10_fw_main.scad>
use <parts/11_fw_flaps.scad>
use <parts/12_fw_endplates.scad>
use <parts/13_fw_mounts.scad>
use <parts/14_rear_wing.scad>
use <parts/15_beam_wing.scad>
use <parts/16_rw_pylon.scad>
use <parts/17_mirror.scad>
use <parts/18_helmet.scad>
use <parts/19_cockpit_trim.scad>
use <parts/20_steering_wheel.scad>
use <parts/21_susp_front.scad>
use <parts/22_susp_rear.scad>
use <parts/23_brake_scoop_front.scad>
use <parts/24_brake_scoop_rear.scad>
use <parts/25_tire_front.scad>
use <parts/26_rim_front.scad>
use <parts/27_tire_rear.scad>
use <parts/28_rim_rear.scad>
use <parts/29_gearbox_crash.scad>
use <parts/30_cameras_antennas.scad>

module f1_v2() {
    // 카본 계열
    color("DimGray") {
        floor_plate(); floor_fences(); gearbox_crash(); fw_endplates();
    }
    color("FireBrick") diffuser();
    // 바디
    color("Crimson") { nose(); chassis(); engine_cover(); sidepod(); }
    color("Black") {
        airbox(); halo(); mirror_assembly(); steering_wheel();
        cameras_antennas();
    }
    // 윙
    color("FireBrick") {
        fw_main(); fw_flaps(); rear_wing(); beam_wing(); rw_pylon();
    }
    color("Gold")      helmet();
    color("DarkSlateGray") cockpit_trim();
    color("Gray") {
        susp_front(); susp_rear(); brake_scoop_front(); brake_scoop_rear();
    }
    // 휠 — L은 +X, R은 Y축 180° 회전(아웃보드 페이스 반전)
    color("Black") {
        translate([ WHF_X, AXF_Y, WH_Z]) tire_front();
        translate([ WHR_X, AXR_Y, WH_Z]) tire_rear();
        translate([-WHF_X, AXF_Y, WH_Z]) rotate([0, 180, 0]) tire_front();
        translate([-WHR_X, AXR_Y, WH_Z]) rotate([0, 180, 0]) tire_rear();
    }
    color("DarkSlateGray") {
        translate([ WHF_X, AXF_Y, WH_Z]) rim_front();
        translate([ WHR_X, AXR_Y, WH_Z]) rim_rear();
        translate([-WHF_X, AXF_Y, WH_Z]) rotate([0, 180, 0]) rim_front();
        translate([-WHR_X, AXR_Y, WH_Z]) rotate([0, 180, 0]) rim_rear();
    }
}

f1_v2();
