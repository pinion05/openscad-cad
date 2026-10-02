// 16 리어윙 쌍둥 스완넥 파일론 (샤크핀 → RW 메인 LE 저면)
include <../params.scad>
use <../lib.scad>

module rw_pylon()
for (s = [-1, 1]) {
    rod([s * RW_PYL_X, RW_PYL[0][0], RW_PYL[0][1]],
        [s * RW_PYL_X, RW_PYL[1][0], RW_PYL[1][1]], RW_PYL_OD, 40);
    rod([s * RW_PYL_X, RW_PYL[1][0], RW_PYL[1][1]],
        [s * RW_PYL_X, RW_PYL[2][0], RW_PYL[2][1]], RW_PYL_OD, 40);
}

rw_pylon();
