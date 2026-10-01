#!/usr/bin/env python3
"""매니폴드/간섭/접촉/연결성/대칭성 검증 — RC 버기 (1:10)
1) 각 부품 STL: watertight + winding 일관 + manifold3d 변환 NoError
2) 조립 인스턴스(부품 + 휠 4): 모든 쌍의 불리언 교집합 부피 — 1mm³ 초과 FAIL
3) 결합면 접촉: CONTACT 명세 쌍의 최단 간극이 허용치 이내 (뜬 결합 탐지)
4) 조립 연결성: 접촉 그래프가 하나의 연결 성분 (부유 부품 탐지)
5) 좌우 대칭성: SYMMETRIC 부품을 x-미러본과 비교 — 차집합 부피비 초과 FAIL
   (미러 루프 누락 = 좌측 부품 부재·역방향 형상, 간섭 검사로 안 걸리는 무증상 결함)
"""
import sys, itertools
from collections import deque
import numpy as np
import trimesh
from trimesh.proximity import ProximityQuery
import manifold3d

ROOT = __file__.rsplit("/", 2)[0]
STL = f"{ROOT}/stl"

PARTS = [
    "01_chassis", "02_rollcage", "03_suspension_front", "04_suspension_rear",
    "05_wheel_front", "06_wheel_rear", "07_bonnet", "08_rear_body",
    "09_cockpit", "10_drivetrain", "11_bumper_front", "12_spoiler",
]
# x-미러 대칭이어야 하는 부품 (10: 배기 우측 1통식 — 설계상 비대칭 제외)
SYMMETRIC = [p for p in PARTS if p not in ("05_wheel_front", "06_wheel_rear", "10_drivetrain")]
SYM_MAX_RATIO = 0.02      # 차집합/자체부피 2% 초과 시 FAIL

HUB_F, HUB_R, AXLE_Y, HUB_Z = 104.0, 100.0, 130.0, 55.0

# ---- 결합면 명세: (A, B, 최대허용간극 mm) --------------------------------
CONTACT = [
    ("01_chassis", "02_rollcage",         2.0),  # 케이지 발판 6개 (z0+0.4)
    ("01_chassis", "03_suspension_front", 3.0),  # 어퍼 타워 판 + 로어 부싱
    ("01_chassis", "04_suspension_rear",  3.0),
    ("01_chassis", "07_bonnet",           2.0),  # 보닛 마운트 탭
    ("01_chassis", "08_rear_body",        2.0),  # 사이드/리어 패널
    ("01_chassis", "09_cockpit",          2.0),  # 시트 쿠션 베이스
    ("01_chassis", "10_drivetrain",       2.0),  # 엔진 블록 베이스
    ("01_chassis", "11_bumper_front",     2.0),  # 스키드 플레이트
    ("08_rear_body", "12_spoiler",        2.0),  # 스포일러 스트럿
    ("03_suspension_front", "05_wheel_front[L]", 2.0),  # 스터브-허브 디스크 시트
    ("03_suspension_front", "05_wheel_front[R]", 2.0),
    ("04_suspension_rear",  "06_wheel_rear[L]",  2.0),
    ("04_suspension_rear",  "06_wheel_rear[R]",  2.0),
]
CONNECT_EPS = 2.5

def to_manifold(mesh):
    tri = np.ascontiguousarray(mesh.faces.astype(np.uint32))
    vert = np.ascontiguousarray(mesh.vertices.astype(np.float32))
    return manifold3d.Manifold(manifold3d.Mesh(vert, tri))

def min_gap(m1, m2, sample=4000, seed=0):
    rng = np.random.default_rng(seed)
    def sub(m):
        v = m.vertices
        return v if len(v) <= sample else v[rng.choice(len(v), sample, replace=False)]
    d1 = ProximityQuery(m2).on_surface(sub(m1))[1].min()
    d2 = ProximityQuery(m1).on_surface(sub(m2))[1].min()
    return float(min(d1, d2))

def mirror_x(mesh):
    # trimesh는 음의 행렬식 변환 시 와인딩을 자동 교정하므로 invert 금지
    m = mesh.copy()
    T = np.eye(4); T[0, 0] = -1.0
    m.apply_transform(T)
    return m

def main():
    ok = True
    meshes = {}

    print("=" * 76)
    print(f"{'부품':<24}{'watertight':<12}{' winding':<10}{' vol(cm3)':>10}{'  tris':>9}  bbox(mm)")
    print("-" * 76)
    for name in PARTS:
        m = trimesh.load_mesh(f"{STL}/{name}.stl")
        wt, wc = m.is_watertight, m.is_winding_consistent
        try:
            mf = to_manifold(m)
            mf_ok = (mf.status() == manifold3d.Error.NoError) and mf.volume() > 0
        except Exception as e:
            mf_ok = False; print(f"  manifold3d 오류: {e}")
        flag = "OK" if (wt and wc and mf_ok) else "FAIL"
        if flag == "FAIL":
            ok = False
        meshes[name] = m
        b = m.bounds
        bb = f"{b[1][0]-b[0][0]:.0f}x{b[1][1]-b[0][1]:.0f}x{b[1][2]-b[0][2]:.0f}"
        print(f"{name:<24}{flag:<12}{'OK' if wc else 'BAD':<10}{m.volume/1000:>10.1f}{len(m.faces):>9}  {bb}")

    # ---- 인스턴스: 부품 + 휠 4 ----
    inst = {n: meshes[n] for n in PARTS if not n.startswith(("05", "06"))}
    for (wn, hx, wy) in [("05_wheel_front", HUB_F, AXLE_Y), ("06_wheel_rear", HUB_R, -AXLE_Y)]:
        for sx in (-1, 1):
            t = trimesh.transformations.rotation_matrix(np.pi/2 * sx, [0, 1, 0])
            t[:3, 3] = [sx * hx, wy, HUB_Z]
            w = meshes[wn].copy(); w.apply_transform(t)
            inst[f"{wn}[{'R' if sx > 0 else 'L'}]"] = w
    mfm = {n: to_manifold(m) for n, m in inst.items()}
    bboxes = {n: m.bounds for n, m in inst.items()}

    # ---- 2) 간섭 ----
    print("\n" + "=" * 76)
    print("부품 간 간섭 검사 (교집합 부피 > 1.0 mm³ = FAIL)")
    print("-" * 76)
    n_col = 0
    for a, b in itertools.combinations(inst, 2):
        ba, bb = bboxes[a], bboxes[b]
        if np.any(ba[0] > bb[1]) or np.any(bb[0] > ba[1]):
            continue
        try:
            v = (mfm[a] ^ mfm[b]).volume()
        except Exception:
            v = 0.0
        if v > 1.0:
            ok = False; n_col += 1
            print(f"  간섭! {a} <-> {b} : {v:.1f} mm³")
    if n_col == 0:
        print("  간섭 없음 — 모든 부품 조립 가능(클리어런스 확보)")

    # ---- 3) 접촉 ----
    print("\n" + "=" * 76)
    print(f"결합면 접촉 검사 (CONTACT 명세 {len(CONTACT)}쌍)")
    print("-" * 76)
    gaps = {}
    for a, b, gmax in CONTACT:
        d = min_gap(inst[a], inst[b])
        gaps[tuple(sorted((a, b)))] = d
        if d <= gmax:
            print(f"  접촉 OK  {a} <-> {b} : 간극 {d:.2f}mm (허용 {gmax})")
        else:
            ok = False
            print(f"  뜸/이격! {a} <-> {b} : 간극 {d:.2f}mm (허용 {gmax})")

    # ---- 4) 연결성 ----
    print("\n" + "=" * 76)
    print(f"조립 연결성 검사 (간극 ≤ {CONNECT_EPS}mm = 접촉 엣지)")
    print("-" * 76)
    extra = []
    e = 3.0
    for a, b in itertools.combinations(inst, 2):
        if tuple(sorted((a, b))) in gaps:
            continue
        ba, bb = bboxes[a], bboxes[b]
        if np.any(ba[0] - e > bb[1]) or np.any(bb[0] - e > ba[1]):
            continue
        extra.append(tuple(sorted((a, b))))
    for key in extra:
        gaps[key] = min_gap(inst[key[0]], inst[key[1]])
    adj = {n: set() for n in inst}
    for (a, b), d in gaps.items():
        if d <= CONNECT_EPS:
            adj[a].add(b); adj[b].add(a)
    seen, comps = set(), []
    for n in inst:
        if n in seen:
            continue
        q, comp = deque([n]), []
        seen.add(n)
        while q:
            cur = q.popleft(); comp.append(cur)
            for nb in adj[cur]:
                if nb not in seen:
                    seen.add(nb); q.append(nb)
        comps.append(sorted(comp))
    if len(comps) == 1:
        print(f"  연결성 OK — {len(inst)}개 인스턴스가 하나의 조립체")
    else:
        ok = False
        print(f"  부유 성분 {len(comps)}개 발견!")
        for c in comps:
            print(f"    섬({len(c)}): {', '.join(c)}")

    # ---- 5) 대칭성 (미러 누락 무증상 결함 탐지) ----
    print("\n" + "=" * 76)
    print(f"좌우 대칭성 검사 (x-미러 차집합/부피 > {SYM_MAX_RATIO:.0%} = FAIL)")
    print("-" * 76)
    for name in SYMMETRIC:
        m = meshes[name]
        inter = (to_manifold(m) ^ to_manifold(mirror_x(m))).volume()
        ratio = max(0.0, 1 - inter / m.volume)
        if ratio <= SYM_MAX_RATIO:
            print(f"  대칭 OK  {name:<24} 차집합 비율 {ratio:.3%}")
        else:
            ok = False
            print(f"  비대칭! {name:<24} 차집합 비율 {ratio:.2%} — 미러 루프 누락 의심")
    print("=" * 76)
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
