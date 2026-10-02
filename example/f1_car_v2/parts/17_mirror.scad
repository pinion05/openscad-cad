// 17 미러 — 스토크 + 하우징 + 글래스 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module mirror_assembly()
for (s = [-1, 1]) {
    rod(mir(MIR_BASE, s), mir([30, 66.5, 56], s), 2.2, 24);
    translate(mir([31, 68.1, 56.5], s)) rotate([90, 0, 0])
        linear_extrude(2.2) polygon(rrpts(7, 4.5, 1.2));       // 하우징
    translate(mir([31, 67.4, 56.5], s)) rotate([90, 0, 0])
        linear_extrude(0.5) polygon(rrpts(5.5, 3, 0.8));       // 글래스
}

mirror_assembly();
