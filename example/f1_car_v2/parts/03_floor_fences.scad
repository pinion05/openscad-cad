// 03 플로어 에지 윙 — 업턴된 에지 + 전방 미니 펜스 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module floor_fences()
for (s = [-1, 1]) {
    loftr([for (r = FEW_SEC)  [r[0], s * r[1], r[2], r[3], r[4], r[5]]]);
    loftr([for (r = FEW2_SEC) [r[0], s * r[1], r[2], r[3], r[4], r[5]]]);
}

floor_fences();
