// ===== 공용 프리미티브 (params 의존 없음 — use로 포함. 함정 1) =====

// 두 점을 잇는 캡슐. 끝단이 od/2 만큼 뻗는다 (함정 3)
module rod(p1, p2, od, fn = 56)
    hull() { translate(p1) sphere(d = od, $fn = fn);
             translate(p2) sphere(d = od, $fn = fn); }

function mir(p, s = 1) = [s * p.x, p.y, p.z];

// --- 라운디드 사각 2D 폴리곤 (CCW) ---
function arc_pt(cx, cy, r, a) = [cx + r * cos(a), cy + r * sin(a)];
function rrpts(w, h, r, n = 4) =
    let (x = w / 2 - r, y = h / 2 - r)
    concat(
        [for (i = [0:n]) arc_pt( x, -y, r, -90 + 90 * i / n)],
        [for (i = [0:n]) arc_pt( x,  y, r,   0 + 90 * i / n)],
        [for (i = [0:n]) arc_pt(-x,  y, r,  90 + 90 * i / n)],
        [for (i = [0:n]) arc_pt(-x, -y, r, 180 + 90 * i / n)]);

// y 위치의 XZ 단면 슬래브 (중심 x0/zc, 폭 w/높이 h, 모서리 r).
// 회전 매핑: 2D x→차량 X, 2D y→차량 Z, 돌출 +z→−Y (y..y+0.02 전방 전용, 함정 20)
module slabr(y, x0, w, h, zc, r)
    translate([x0, y + 0.02, zc]) rotate([90, 0, 0])
        linear_extrude(0.02) polygon(rrpts(w, h, r));

// 단면 체인 loft: sec = [[y, x0, w, h, zc, r], ...]
module loftr(sec)
    for (i = [0 : len(sec) - 2])
        hull() {
            slabr(sec[i][0],     sec[i][1],     sec[i][2],     sec[i][3],     sec[i][4],     sec[i][5]);
            slabr(sec[i + 1][0], sec[i + 1][1], sec[i + 1][2], sec[i + 1][3], sec[i + 1][4], sec[i + 1][5]);
        }

// 라운디드 박스 (z0..z1 수직, 평면 모서리 r)
module rbox(xc, yc, z0, z1, dx, dy, r, fn = 32)
    hull() for (px = [-1, 1], py = [-1, 1])
        translate([xc + px * (dx / 2 - r), yc + py * (dy / 2 - r), z0])
            cylinder(r = r, h = z1 - z0, $fn = fn);

// --- NACA 계열 에어포일 (LE 원점, 2D +x = 현 방향) ---
function _yt(x, c, t) = 5 * t * c * (0.2969*sqrt(x) - 0.1260*x - 0.3516*x*x
    + 0.2843*x*x*x - 0.1036*x*x*x*x);
function _yc(x, c, m) = 4 * m * c * x * (1 - x);
function naca_pts(c, t, m, n = 12) =
    concat(
        [for (i = [0:n])     let (x = i / n)     [x*c,  _yt(x, c, t) + _yc(x, c, m)]],
        [for (i = [n-1:-1:0]) let (x = i / n)    [x*c, -_yt(x, c, t) + _yc(x, c, m)]]);

// 슬라이스 3D 링: v=[x, yle, zle, c, aoa, th, cam] → 받각 회전된 naca 점의 링
// (th/cam은 mm — 현 대비 비율로 정규화)
function wring(v, n = 12) =
    let (c = v[3], t = v[5] / c, m = v[6] / c, pts = naca_pts(c, t, m, n),
         ca = cos(v[4]), sa = sin(v[4]))
    // 코드 방향 (ca,sa) + 두께/캠버 수직 방향 (-sa,ca) — 2D y 누락 금지
    [for (p = pts) [v[0], v[1] + p[0] * ca - p[1] * sa, v[2] + p[0] * sa + p[1] * ca]];

// 진짜 로프트 윙 — polyhedron 스트립. hull 체인은 캠버진 하면을 볼록 껍질로
// 채워(LE→TE 직선 웨지) 요소가 처지므로 쓰지 않는다
module wing3(sl, n = 12) {
    rings = [for (v = sl) wring(v, n)];
    ns = len(rings);
    m = len(rings[0]);
    pts = [for (r = rings, p = r) p];
    function ix(i, k) = i * m + (k % m);
    faces = concat(
        // 측면 스트립 (사중면 → 삼각형 2) — 외향 노멀 권선(캡과 일치)
        [for (i = [0 : ns - 2], k = [0 : m - 1])
            each [[ix(i, k), ix(i, k + 1), ix(i + 1, k + 1)],
                  [ix(i, k), ix(i + 1, k + 1), ix(i + 1, k)]]],
        // 끝 캡 (링은 단순 폴리곤 — 팬 삼각분할)
        [for (k = [1 : m - 2]) [ix(0, 0), ix(0, k + 1), ix(0, k)]],
        [for (k = [1 : m - 2]) [ix(ns - 1, 0), ix(ns - 1, k), ix(ns - 1, k + 1)]]
    );
    polyhedron(points = pts, faces = faces, convexity = 4);
}

// 반쪽 슬라이스 → x-대칭 전체. 규약: half는 센터(x=0)→팁 순서(내림차순 x).
// 결과는 x 오름차순 체인. x=0 센터만 중복 제외 (그 외 전부 미러)
function wsym(half) =
    concat([for (i = [len(half) - 1 : -1 : 0]) half[i]],
           [for (i = [0 : len(half) - 1]) if (abs(half[i][0]) > 1e-9)
               concat([-half[i][0]], [for (j = [1 : len(half[i]) - 1]) half[i][j]])]);

// 환(링), 축 Z
module ann(r_in, r_out, h, fn = 96)
    difference() { cylinder(r = r_out, h = h, center = true, $fn = fn);
                   cylinder(r = r_in,  h = h + 2, center = true, $fn = fn); }

// 리스트 전체 x반전+순서 역행 (센터 구간 없는 플랩 등 — 좌우 별도 wing3 호출용).
// x반전만 하면 행렬식이 음수가 되어 권선이 뒤집힌다 → 순서 역행으로 상쇄
function msym(half) =
    [for (i = [len(half) - 1 : -1 : 0])
        concat([-half[i][0]], [for (j = [1 : len(half[i]) - 1]) half[i][j]])];
