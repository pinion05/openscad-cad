// 02 리어 디퓨저 — 확장 램프 + 스트레이크 + 측벽
include <../params.scad>
use <../lib.scad>

module diffuser() {
    loftr(DIFF_SEC);
    // 스트레이크 4 (램프 상면에서 솟음 — 부품 내부 겹침)
    for (x0 = [-30, -12, 12, 30])
        loftr([for (s = DIFF_TOP) [s[0], x0, 1.2, 6.5, s[1] + 2.6, 0.6]]);
    // 측벽 2
    for (x0 = [-49.4, 49.4])
        loftr([for (s = DIFF_TOP) [s[0], x0, 1.6, 9.5, s[1] + 4.2, 0.8]]);
}

diffuser();
