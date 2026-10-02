// 25 프런트 타이어 — 회전체 단면 ($fn=200, 라운디드 숄더)
include <../params.scad>
use <../lib.scad>

function tire_prof(hw, r) = [
    [r - 12.6, -(hw - TIRE_BEAD)], [r - 10.0, -(hw - 1.5)], [r - 6.0, -(hw - 0.55)],
    [r - 3.0,  -hw + 0.1],         [r - 1.2,  -(hw - 1.0)], [r - 0.1,  -(hw - 3.2)],
    [r,        -(hw - 7)],         [r,         0],
    [r,         hw - 7],           [r - 0.1,   hw - 3.2],    [r - 1.2,  hw - 1.0],
    [r - 3.0,   hw - 0.1],         [r - 6.0,   hw - 0.55],   [r - 10.0, hw - 1.5],
    [r - 12.6,  hw - TIRE_BEAD]];

module tire_front()
    rotate([0, 90, 0]) rotate_extrude($fn = TIR_FN)
        polygon(tire_prof(TIRF_W / 2, TIR_R));

tire_front();
