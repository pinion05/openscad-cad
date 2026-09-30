/* 02. 롤케이지 — A후프(윈드실드)·B후프(메인)·루프 레일+X·리어 스테이+X·도어바 X */
include <../params.scad>
include <../lib.scad>

module part_rollcage() {
    for (s = [-1, 1]) {
        /* A후프: 발 → 어깨 → 탑 (후방倾) */
        foot(s*a_foot[0], a_foot[1]);
        rod([s*a_foot[0], a_foot[1], fz(cage_od)], [s*a_sh[0],  a_sh[1],  a_sh[2]],  cage_od);
        rod([s*a_sh[0],    a_sh[1],  a_sh[2]],     [s*a_top[0], a_top[1], a_top[2]], cage_od);
        /* B후프: 발 → 탑 */
        foot(s*b_foot[0], b_foot[1]);
        rod([s*b_foot[0], b_foot[1], fz(cage_od)], [s*b_top[0], b_top[1], b_top[2]], cage_od);
        /* 루프 레일 (A탑→B탑) */
        rod([s*a_top[0], a_top[1], a_top[2]], [s*b_top[0], b_top[1], b_top[2]], cage_od);
        /* 리어 스테이 (B탑→테일 플로어) */
        foot(s*stay_foot[0], stay_foot[1], w = 40);
        rod([s*b_top[0], b_top[1], b_top[2]],
            [s*stay_foot[0], stay_foot[1], fz(cage_od)], cage_od);
        /* 도어바 (로어/미들 + 대각 X) */
        rod([s*545,  380, 460], [s*545, -390, 460], 36);
        rod([s*545,  380, 760], [s*545, -390, 760], tube_sub);
        rod([s*545,  380, 760], [s*545, -390, 460], tube_sub);
        rod([s*545,  380, 460], [s*545, -390, 760], tube_sub);
    }
    /* 상부 크로스바 (A탑 / B탑) */
    rod([-a_top[0], a_top[1], a_top[2]], [a_top[0], a_top[1], a_top[2]], cage_od);
    rod([-b_top[0], b_top[1], b_top[2]], [b_top[0], b_top[1], b_top[2]], cage_od);
    /* 루프 X + 리어 스테이 X */
    rod([ a_top[0], a_top[1], a_top[2]], [-b_top[0], b_top[1], b_top[2]], tube_sub);
    rod([-a_top[0], a_top[1], a_top[2]], [ b_top[0], b_top[1], b_top[2]], tube_sub);
    /* 윈드실드 하단 바 (A후프 튜브에 용접) */
    rod([540, 407, ws_bar_z], [-540, 407, ws_bar_z], 32);
}

part_rollcage();
