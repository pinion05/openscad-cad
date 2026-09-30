/* 03. 프런트 서스펜션 — 더블 위시본 A-arm + 코일오버 쇼크 좌우 2세트
   하나의 부품으로 출력해 섀시 위에 올려 조립(볼트 체결 가정) */
include <../params.scad>
include <../lib.scad>

ay  = axle_f_y;      // 액슬 y = +130
kx  = knk_f;         // 너클 x  = 100
eye = [92, 118, 58];   // 쇼크 하단 아이 (휠 비드 홀 r30 내부 유지)

module part_susp_front() {
    for (s = [-1, 1]) {
        // 로어 A-arm: 피벗 부싱 2 + 레그 2 (섀시 측면에 볼트 체결)
        for (dy = [-1, 1])
            translate([s*lwr_bush_x, ay + dy*lwr_dy, lwr_z])
                cylinder(d = bush_od, h = 14, center = true, $fn = rod_fn);
        for (dy = [-1, 1])
            rod([s*lwr_bush_x, ay + dy*lwr_dy, lwr_z], [s*kx, ay, 46], arm_od);
        // 너클(업라이트) + 스터브 액슬(휠 장착)
        rod([s*kx, ay, 45], [s*kx, ay, 70], 12);
        rod([s*kx, ay, 55], [s*(kx + 7.6), ay, 55], 9);
        // 어퍼 타워(섀시 상면) + 어퍼 아암
        translate([s*upr_piv_x, ay, z0]) plate(10, 16, 0, upr_z - z0 - 4, r = 3);
        rod([s*(upr_piv_x - 5), ay, upr_z], [s*(upr_piv_x + 5), ay, upr_z], bush_od);
        rod([s*upr_piv_x, ay, upr_z], [s*(kx - 3), ay, 66], arm_od);
        // 쇼크 타워(외측 노출) + 보스
        translate([s*tower_fx, tower_fy, z0]) plate(6, 12, 0, tower_top - z0 - 5, r = 3);
        rod([s*tower_fx, tower_fy - 6, tower_top], [s*tower_fx, tower_fy + 6, tower_top], bush_od);
        // 쇼크 하단 탭(너클에서 전방 인보드) + 코일오버
        rod([s*kx, ay, 58], [s*eye[0], eye[1], 58], arm_od);
        orient([s*eye[0], eye[1], eye[2]],
               [s*tower_fx, tower_fy, tower_top])
            shock(norm([tower_fx - eye[0], tower_fy - eye[1], tower_top - eye[2]]));
    }
    // 좌우 타워를 잇는 브리지 바
    rod([-tower_fx, tower_fy, tower_top + 5], [tower_fx, tower_fy, tower_top + 5], 8);
}

part_susp_front();
