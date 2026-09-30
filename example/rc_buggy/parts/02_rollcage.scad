/* 02. 롤 케이지 — 6포인트 튜브 구조
   마운트 6개: 프런트 후프 2 + 메인 후프 2 + 리어 스테이 2
   부가 튜브: 루프 레일, 사이드 실 바, 윈드실드 바, 대시 바, 리어 V 브레이스 */
include <../params.scad>
include <../lib.scad>

ftb = z0 + foot_t;   // 발판 상면 높이

module foot(x, y, w = 30)
    translate([x, y, z0]) plate(w, 22, 0, foot_t, r = 6);

module part_rollcage() {
    fx = cage_fx; fy = cage_fy; ft = cage_ft;
    mx = cage_mx; my = cage_my; mt = cage_mt;
    sx = cage_sx; sy = cage_sy;

    // ---- 6개 발판 (리어 스테이 발판은 리어 사이드 패널 간섭 회피 위해 축소) ----
    foot(-fx, fy);  foot(fx, fy);
    foot(-mx, my);  foot(mx, my);
    foot(-sx, sy, w = 18);  foot(sx, sy, w = 18);

    // ---- 프런트 후프 (뒤로 약간 기울어짐) ----
    for (s = [-1, 1]) rod([s*fx, fy, ftb], [s*ft[0], ft[1], ft[2]], tube_od);
    rod([-ft[0], ft[1], ft[2]], [ft[0], ft[1], ft[2]], tube_od);

    // ---- 메인 후프 ----
    for (s = [-1, 1]) rod([s*mx, my, ftb], [s*mt[0], mt[1], mt[2]], tube_od);
    rod([-mt[0], mt[1], mt[2]], [mt[0], mt[1], mt[2]], tube_od);

    // ---- 루프 레일 (프런트 후프 상단 → 메인 후프 상단, 레이크 각) ----
    for (s = [-1, 1]) rod([s*ft[0], ft[1], ft[2]], [s*mt[0], mt[1], mt[2]], tube_od);

    // ---- 리어 스테이 ----
    for (s = [-1, 1]) rod([s*mt[0], mt[1], mt[2]], [s*sx, sy, ftb], tube_od);

    // ---- 리어 V 브레이스 (스테이 상부 40% 지점 크로스바 + 메인 후프 대각) ----
    vb = [mt[0] + 0.4*(sx - mt[0]), mt[1] + 0.4*(sy - mt[1]), mt[2] + 0.4*(ftb - mt[2])];
    rod([-vb[0], vb[1], vb[2]], [vb[0], vb[1], vb[2]], tube_od_s);
    rod([-mt[0], mt[1], mt[2]], [ vb[0], vb[1], vb[2]], tube_od_s);
    rod([ mt[0], mt[1], mt[2]], [-vb[0], vb[1], vb[2]], tube_od_s);

    // ---- 사이드 실 바 (도어 하단, 섀시 상면에 밀착) ----
    for (s = [-1, 1])
        rod([s*fx, fy, z0 + tube_od/2], [s*mx, my, z0 + tube_od/2], tube_od);

    // ---- 윈드실드 바 + 대시 바 (보닛 상단 에지 위 0.5mm 클리어런스) ----
    for (s = [-1, 1]) rod([s*ft[0], ft[1], ft[2]], [s*38, 60, 100], tube_od_s);
    rod([-38, 60, 100], [38, 60, 100], tube_od_s);
}

part_rollcage();
