// 08 사이드포드 — 다운워시 램프 테이퍼 + 인렛 리세스 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module sidepod()
for (s = [-1, 1])
    difference() {
        loftr([for (r = SPOD_SEC) [r[0], s * SPOD_X0, r[1], r[2], r[3], r[4]]]);
        // 인렛 리세스 (전면 2.3mm 깊이)
        rbox(s * SPOD_X0, 39.05, 10, 28, SPOD_INLET[0], SPOD_INLET[3], 2);
    }

sidepod();
