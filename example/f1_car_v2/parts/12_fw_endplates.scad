// 12 프런트 윙 엔드플레이트 + 다이브플레인 (좌우 1부품)
include <../params.scad>
use <../lib.scad>

module fw_endplates()
for (s = [-1, 1]) {
    translate([s * FW_EP_X, 0, 0]) rotate([90, 0, 90])
        linear_extrude(FW_EP_T, center = true) polygon(FW_EP_PTS);
    rod([s * 95.8, 243.5, 21.4], [s * 90, 249, 23.8], 2, 24);  // 다이브플레인
}

fw_endplates();
