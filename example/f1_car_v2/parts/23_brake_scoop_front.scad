// 23 프런트 브레이크 스쿱 — 업라이트 전방 흡기구 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module brake_scoop_front()
for (s = [-1, 1])
    loftr([for (r = SCOOP_F) [r[0], s * r[1], r[2], r[3], r[4], r[5]]]);

brake_scoop_front();
