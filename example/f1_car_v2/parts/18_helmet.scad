// 18 드라이버 헬멧 — 스케일 구 + 바이저 슬롯 + 리어 핀
include <../params.scad>
use <../lib.scad>

module helmet() {
    difference() {
        translate(HELM_C) scale(HELM_SC) sphere(HELM_R, $fn = 96);
        translate([0, 11.5, 57]) cube([16, 3, 6], center = true);   // 바이저
    }
    loftr([[-15, 0, 2.4, 5.5, 64.5, 1], [-5, 0, 2.4, 3.5, 64.0, 1]]);  // 핀
}

helmet();
