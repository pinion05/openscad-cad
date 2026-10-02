// 27 리어 타이어 — 405mm급 와이드 회전체
include <../params.scad>
use <../lib.scad>

function tire_prof_r(hw, r) = [
    [r - 12.6, -(hw - TIRE_BEAD - 5)], [r - 10.0, -(hw - 1.7)], [r - 6.0, -(hw - 0.6)],
    [r - 3.0,  -hw + 0.1],             [r - 1.2,  -(hw - 1.1)], [r - 0.1,  -(hw - 3.4)],
    [r,        -(hw - 8)],             [r,         0],
    [r,         hw - 8],               [r - 0.1,   hw - 3.4],    [r - 1.2,  hw - 1.1],
    [r - 3.0,   hw - 0.1],             [r - 6.0,   hw - 0.6],    [r - 10.0, hw - 1.7],
    [r - 12.6,  hw - TIRE_BEAD - 5]];

module tire_rear()
    rotate([0, 90, 0]) rotate_extrude($fn = TIR_FN)
        polygon(tire_prof_r(TIRR_W / 2, TIR_R));

tire_rear();
