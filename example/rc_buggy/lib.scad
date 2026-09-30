/* =====================================================================
   공용 헬퍼 라이브러리 — params.scad 를 include 한 뒤 사용
   ===================================================================== */

/* 두 점을 잇는 둥근 끝 튜브(캡슐) — 용접 조인트처럼 자연스럽게 합쳐짐 */
module rod(p1, p2, od, fn=rod_fn)
    hull() {
        translate(p1) sphere(d=od, $fn=fn);
        translate(p2) sphere(d=od, $fn=fn);
    }

/* 로컬 +Z 축을 p1→p2 방향으로 정렬 (자식 배치용)
   Rz(φ)·Ry(θ)·ẑ = v̂  →  외부 Z 회전, 내부 Y 회전 순서 */
module orient(p1, p2) {
    v = p2 - p1;
    h = norm([v.x, v.y]);
    translate(p1)
        rotate([0, 0, atan2(v.y, v.x)])
        rotate([0, atan2(h, v.z), 0])
        children();
}

/* 모서리가 둥근 수직 판 (x=폭, y=길이, z0~z1) */
module plate(x, y, z0, z1, r=4, fn=32)
    hull()
        for (px = [-1, 1], py = [-1, 1])
            translate([px*(x/2 - r), py*(y/2 - r), z0])
                cylinder(r = r, h = z1 - z0, $fn = fn);

/* 코일오버 스프링 (로컬 +Z 축, z0~z1 구간에 링 n개) */
module coil(z0, z1, R = spring_R, t = spring_t, n = spring_n)
    for (i = [0 : n-1])
        translate([0, 0, z0 + i*(z1 - z0)/(n - 1)])
            rotate_extrude($fn = coil_fn)
                translate([R, 0]) circle(d = t, $fn = 16);

/* 쇼크업소버 (로컬 +Z 축, 하단 아이 z=0, 전장 L) */
module shock(L) {
    cylinder(d = shock_body_od, h = L*0.45, $fn = rod_fn);              // 댐퍼 바디
    translate([0, 0, L*0.45])
        cylinder(d = shock_rod_od, h = L*0.45 - 4, $fn = rod_fn);       // 로드
    coil(L*0.14, L*0.72);                                               // 스프링
    translate([0, 0, 2])   cube([10, 10, 4], center = true);            // 하단 아이 러그
    translate([0, 0, L-2]) cube([10, 10, 4], center = true);            // 상단 아이 러그
}
