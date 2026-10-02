// 15 빔 윙 — 2엘리먼트 + 기어박스 마운트 플레이트
include <../params.scad>
use <../lib.scad>

module beam_wing() {
    wing3(BEAM_E1);
    wing3(BEAM_E2);
    for (s = [-1, 1])   // 마운트 플레이트 ±x (YZ 평면 판)
        translate([s * (BEAM_PLATE[2] + 1.25), 0, 0]) rotate([90, 0, 90])
            linear_extrude(2.5, center = true)
                polygon([[BEAM_PLATE[1], BEAM_PLATE[3]], [BEAM_PLATE[0], BEAM_PLATE[3]],
                         [BEAM_PLATE[0], BEAM_PLATE[4]], [BEAM_PLATE[1], BEAM_PLATE[4]]]);
}

beam_wing();
