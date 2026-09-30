/* =====================================================================
   공용 헬퍼 라이브러리 — params.scad 를 include 한 뒤 사용
   ===================================================================== */

/* 두 점을 잇는 둥근 끝 튜브(캡슐) — 용접 조인트처럼 자연스럽게 합쳐짐
   끝단이 od/2 만큼 뻗으므로 타 부품과의 경계는 그만큼 여유 확보 */
module rod(p1, p2, od, fn = rod_fn)
    hull() {
        translate(p1) sphere(d = od, $fn = fn);
        translate(p2) sphere(d = od, $fn = fn);
    }

/* 로컬 +Z 축을 p1→p2 방향으로 정렬 (외부 Z 회전 → 내부 Y 회전 순서) */
module orient(p1, p2) {
    v = p2 - p1;
    h = norm([v.x, v.y]);
    translate(p1)
        rotate([0, 0, atan2(v.y, v.x)])
        rotate([0, atan2(h, v.z), 0])
        children();
}

/* 모서리가 둥근 수직 판 (x=폭, y=길이, z0~z1) */
module plate(x, y, z0, z1, r = 4, fn = 32)
    hull()
        for (px = [-1, 1], py = [-1, 1])
            translate([px*(x/2 - r), py*(y/2 - r), z0])
                cylinder(r = r, h = z1 - z0, $fn = fn);

/* 플로어 위 결합 발판 — 윗면 z0+cage_foot_t, 관통 로드 시작높이 계산용 함수 */
function fz(od) = z0 + cage_foot_t + od/2 + gap;   // 발판 위 튜브 구심 높이
module foot(x, y, w = foot_w, t = cage_foot_t)
    translate([x, y, z0])
        linear_extrude(t)
            offset(r = w/8) square([w, w], center = true);

/* x-미러 포인트 (s=±1) */
function mir(p, s) = [s*p[0], p[1], p[2]];

/* 코일오버 스프링 (로컬 +Z 축, z0~z1 구간에 링 n개) */
module coil(z0, z1, R = spring_R, t = spring_t, n = spring_n)
    for (i = [0 : n-1])
        translate([0, 0, z0 + i*(z1 - z0)/(n - 1)])
            rotate_extrude($fn = coil_fn)
                translate([R, 0]) circle(d = t, $fn = 16);

/* 쇼크업소버 바디 (로컬 +Z, 하단 아이 z=0, 전장 L) — orient() 로 배치 */
module shock_body(L) {
    cylinder(d = shock_body_od, h = L*0.42, $fn = rod_fn);
    translate([0, 0, L*0.42])
        cylinder(d = shock_rod_od, h = L*0.52, $fn = rod_fn);
    coil(L*0.10, L*0.68);
    translate([0, 0, 12])  cube([95, 95, 24], center = true);   // 하단 아이
    translate([0, 0, L-12]) cube([95, 95, 24], center = true);  // 상단 아이
}

/* 완전 쇼크업소버: p_bot(하단 아이 중심) → p_top */
module shock(p_bot, p_top)
    orient(p_bot, p_top) shock_body(norm(p_top - p_bot));

/* ---------------------------------------------------------------------
   휠 모듈 — 로컬 축: 휠 축 = +Z (조립 시 ±X 회전 배치), 아웃보드 = +Z
   w = 타이어 폭 (260 프런트 / 320 리어)
   --------------------------------------------------------------------- */
module wheel(w) {
    carcass_r = tire_carcass_r;
    bore_r    = tire_bore_r - rim_gap;      // 림-타이어 맞춤
    // ---- 타이어 카카스 (어깨 찬퍼) ----
    difference() {
        hull() {
            cylinder(r = carcass_r,       h = w - 46, center = true, $fn = wheel_fn);
            cylinder(r = carcass_r - 23,  h = w - 6,  center = true, $fn = wheel_fn);
        }
        translate([0, 0, -w]) cylinder(r = bore_r, h = 2*w, $fn = wheel_fn);
    }
    // ---- 노브 트레드 (와이드는 4행, 표준은 3행 가운데 1/2 피치 스태거) ----
    rows = (w > 290) ? [-105, -35, 35, 105] : [-70, 0, 70];
    for (rz = rows, i = [0 : tread_n - 1])
        rotate([0, 0, i*360/tread_n + (rz == 0 ? 180/tread_n : 0)])
            translate([carcass_r - 1.5 + tread_depth/2, 0, rz])
                cube([tread_depth + 3, tread_len, tread_w], center = true);
    // ---- 림 배럴 + 비드락 링 ----
    barrel = w - 36;
    difference() {
        cylinder(r = bore_r, h = barrel, center = true, $fn = wheel_fn);
        cylinder(r = bore_r - rim_wall, h = barrel + 8, center = true, $fn = wheel_fn);
    }
    for (sz = [-1, 1])
        difference() {
            translate([0, 0, sz*(w/2 - bead_t/2 - 3)])
                cylinder(r = bore_r, h = bead_t, $fn = wheel_fn);
            translate([0, 0, sz*(w/2 - bead_t/2 - 3) - 4])
                cylinder(r = bore_r - rim_wall - 16, h = bead_t + 8, $fn = wheel_fn);
        }
    // ---- 허브 디스크 + 6스포크 + 캡 (딥디시, 아웃보드 +z) ----
    translate([0, 0, w/2 - 40]) cylinder(r = hub_disc_r, h = 24, $fn = rod_fn);
    for (i = [0 : spoke_n - 1])
        rotate([0, 0, i*360/spoke_n])
            translate([157, 0, w/2 - 43]) cube([100, 47, 33], center = true);
    translate([0, 0, w/2 - 60]) cylinder(r = 42, h = 20, $fn = rod_fn);
    // 비드락 볼트 12개 (양측 링, 링 면과 플러시 — 돌출 없음)
    for (sz = [-1, 1], i = [0 : 11])
        rotate([0, 0, i*30 + 15])
            translate([bore_r - 11, 0, sz*(w/2 - bead_t/2 - 3)])
                cylinder(d = 14, h = bead_t, center = true, $fn = 12);
}
