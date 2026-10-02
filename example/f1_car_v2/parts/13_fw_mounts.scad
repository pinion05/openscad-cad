// 13 프런트 윙 스완넥 마운트 플레이트 (노우즈 저면 ↔ 메인 상면, 좌우 1부품)
include <../params.scad>
use <../lib.scad>

module fw_mounts()
for (s = [-1, 1])
    loftr([for (r = FW_MT_SEC) [r[0], s * r[1], r[2], r[3], r[4], r[5]]]);

fw_mounts();
