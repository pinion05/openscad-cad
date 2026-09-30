/* 11. 파워트레인 — 미드 세로형 인라인4(블록·오일팬·헤드·ITB 트럼펫)·
   트랜스+벨하우징·전후 디프·프롭샤프트·하프샤프트+CV·
   3-1 배기 양뱅크→크로스파이프→머플러·라디에이터·냉각호스·연료셀
   X축 CV 실린더는 rotate([0, s*90, 0]) 로 아웃보드 방향 */
include <../params.scad>
include <../lib.scad>

module part_drivetrain() {
    /* ---- 엔진 블록 (테이퍼) + 오일팬 ---- */
    hull() {
        translate([0, -660, 512]) cube([380, 380, 24], center = true);
        translate([0, -660, 778]) cube([2*eng_hw, 400, 24], center = true);
    }
    translate([0, -660, 528]) cube([300, 340, 56], center = true);
    /* ---- 헤드 + ITB 스택 ---- */
    hull() {
        translate([0, -670, 810]) cube([340, 340, 40], center = true);
        translate([0, -670, 850]) cube([2*head_hw, 300, 40], center = true);
    }
    for (yy = itb_y) {
        translate([0, yy, 905]) cylinder(h = 70, d = itb_od, center = true, $fn = rod_fn);
        translate([0, yy, 942]) cylinder(h = 12, d1 = itb_od, d2 = 82, $fn = rod_fn);
    }
    /* ---- 트랜스미션 + 벨하우징 ---- */
    translate([0, -990, 570]) cube([2*trans_hw, 260, 220], center = true);
    translate([0, -875, 645]) rotate([90, 0, 0])
        cylinder(h = 70, d = 300, center = true, $fn = 48);
    /* ---- 디퍼렌셜 (전/후) ---- */
    translate([0,  axle_y, 445]) sphere(d = 2*diff_r, $fn = rod_fn);
    translate([0, -axle_y, 445]) sphere(d = 2*diff_r, $fn = rod_fn);
    translate([0,  1085, 445]) rotate([-90, 0, 0]) cylinder(h = 60, d = 130, center = true, $fn = rod_fn);
    translate([0, -1215, 445]) rotate([-90, 0, 0]) cylinder(h = 60, d = 130, center = true, $fn = rod_fn);
    /* ---- 프로필 샤프트 (전륜 구동) + U조인트 ---- */
    rod([0, -1100, 470], [0, 1100, 445], prop_od);
    translate([0,  1060, 450]) cube([70, 70, 70], center = true);
    translate([0, -1060, 472]) cube([70, 70, 70], center = true);
    /* ---- 하프샤프트 + CV (너클과 0.4, 플로어와 3mm) ---- */
    for (s = [-1, 1]) {
        rod([s*84,  axle_y, 445], [s*576.6,  axle_y, 445], hs_od);
        rod([s*84, -axle_y, 445], [s*556.6, -axle_y, 445], hs_od);
        translate([s*540,  axle_y, 445]) rotate([0, s*90, 0]) cylinder(h = 52, d = 60, center = true, $fn = rod_fn);
        translate([s*520, -axle_y, 445]) rotate([0, s*90, 0]) cylinder(h = 52, d = 60, center = true, $fn = rod_fn);
    }
    /* ---- 배기: 3-1 헤더 양뱅크 → 콜렉터 → 크로스 → 머플러 → 테일 ---- */
    for (i = [0 : 2]) {
        yy = [-620, -700, -780][i];  zz = [800, 780, 760][i];
        rod([ 205, yy, zz], [ 300, -1075 - i*15, 605 - i*7], 44);
        rod([-205, yy, zz], [-230, -1055 - i*15, 572],       44);
    }
    translate([ 305, -1112, 598]) sphere(d = 96, $fn = rod_fn);
    translate([-225, -1092, 570]) sphere(d = 96, $fn = rod_fn);
    rod([ 310, -1120, 600], [ 310, -1268, 602], 76);
    rod([-225, -1092, 570], [-235, -1200, 570], 80);
    rod([-235, -1200, 570], [ 280, -1240, 585], 72);
    rod([ 280, -1240, 585], [ 280, -1268, 612], 72);
    translate([muff_x, (muff_y0 + muff_y1)/2, muff_z]) rotate([90, 0, 0])
        cylinder(h = muff_y1 - muff_y0, d = muff_od, center = true, $fn = 48);
    rod([muff_x, -1598, 660], [330, -1690, 690], 70);              // 테일파이프
    /* ---- 라디에이터 (노즈 슬로프 병행, 후경사 14°) ---- */
    translate([0, (rad_y0 + rad_y1)/2, 770]) rotate([-14, 0, 0]) {
        cube([rad_hw*2, 56, 160], center = true);
        for (s = [-1, 1])
            translate([s*(rad_hw + 8), 0, 0]) cube([76, 72, 150], center = true);
    }
    /* ---- 냉각 호스 (라디에이터 → 중앙 터널 → 엔진) ---- */
    for (s = [-1, 1]) {
        rod([s*258, 1398, 722], [s*60, 1090, 470], 44);
        rod([s*60, 1090, 470],  [s*60,  -350, 470], 44);
        rod([s*60,  -350, 470], [s*192,  -490, 528], 44);
    }
    /* ---- 연료셀 + 필러 (테일판/랙 다리 회피) ---- */
    translate([0, -1536, 560])
        cube([2*fuel_hw, fuel_y1 - fuel_y0, fuel_z1 - fuel_z0], center = true);
    rod([180, -1520, 650], [300, -1552, 868], 50);
    translate([300, -1555, 876]) cylinder(h = 14, d = 90, center = true, $fn = rod_fn);
    /* ---- 엔진 마운트 다리 (플로어 위 0.4, 블록 측면) ---- */
    for (s = [-1, 1], yy = [-540, -820]) {
        translate([s*195, yy, z0])
            linear_extrude(14) offset(r = 6) square([60, 60], center = true);
        rod([s*195, yy, 442], [s*195, yy, 505], 30);
    }
}

part_drivetrain();
