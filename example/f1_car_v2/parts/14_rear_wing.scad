// 14 리어 윙 — 메인 + DRS 플랩 + 루브레 엔드플레이트 + DRS 포드 (1부품)
include <../params.scad>
use <../lib.scad>

module rear_wing() {
    wing3(RW_MAIN);
    wing3(RW_FLAP);
    for (s = [-1, 1])
        difference() {
            translate([s * RW_EP_X, 0, 0]) rotate([90, 0, 90])
                linear_extrude(RW_EP_T, center = true) polygon(RW_EP_PTS);
            // 루브레 3슬롯 (상단 전방)
            for (i = [0:2])
                translate([s * RW_EP_X, -249 - i * 4.5, 84.5 + i * 2.2])
                    cube([4, 12, 1.6], center = true);
        }
    // DRS 액추에이터 포드 (플랩 탑 센터)
    translate([0, RW_DRS[0], RW_DRS[1] + RW_DRS[3] / 2]) rotate([90, 0, 90])
        linear_extrude(RW_DRS[4], center = true) polygon(rrpts(RW_DRS[2], RW_DRS[3], 1));
}

rear_wing();
