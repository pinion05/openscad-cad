/* 04. 리어 서스펜션 — 프런트와 동일한 더블 위시본 구조, 쇼크는 액슬 뒤쪽으로 배치 */
include <../params.scad>
include <../lib.scad>

ay  = axle_r_y;          // 액슬 y = -130
kx  = knk_r;             // 너클 x  = 96
eye = [88, -140, 58];    // 쇼크 하단 아이 (액슬 후방, 비드 홀 r30 회피 인보드)

module part_susp_rear() {
    for (s = [-1, 1]) {
        // 로어 A-arm
        for (dy = [-1, 1])
            translate([s*lwr_bush_x, ay + dy*lwr_dy, lwr_z])
                cylinder(d = bush_od, h = 14, center = true, $fn = rod_fn);
        for (dy = [-1, 1])
            rod([s*lwr_bush_x, ay + dy*lwr_dy, lwr_z], [s*kx, ay, 46], arm_od);
        // 너클 + 스터브 액슬
        rod([s*kx, ay, 45], [s*kx, ay, 70], 12);
        rod([s*kx, ay, 55], [s*(kx + 7.6), ay, 55], 9);
        // 어퍼 타워 + 아암
        translate([s*upr_piv_x, ay, z0]) plate(10, 16, 0, upr_z - z0 - 4, r = 3);
        rod([s*(upr_piv_x - 5), ay, upr_z], [s*(upr_piv_x + 5), ay, upr_z], bush_od);
        rod([s*upr_piv_x, ay, upr_z], [s*(kx - 3), ay, 66], arm_od);
        // 쇼크 타워(리어 패널 바로 앞) + 보스
        translate([s*tower_rx, tower_ry, z0]) plate(6, 12, 0, tower_top - z0 - 5, r = 3);
        rod([s*tower_rx, tower_ry - 6, tower_top], [s*tower_rx, tower_ry + 6, tower_top], bush_od);
        // 쇼크 하단 탭(너클에서 후방) + 코일오버
        rod([s*kx, ay, 58], [s*eye[0], eye[1], 58], arm_od);
        orient([s*eye[0], eye[1], eye[2]],
               [s*tower_rx, tower_ry, tower_top])
            shock(norm([tower_rx - eye[0], tower_ry - eye[1], tower_top - eye[2]]));
    }
    // 좌우 타워 브리지
    rod([-tower_rx, tower_ry, tower_top + 5], [tower_rx, tower_ry, tower_top + 5], 8);
}

part_susp_rear();
