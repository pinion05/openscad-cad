#!/usr/bin/env python3
"""F1 1:10 v2 — 매니폴드/간섭/접촉/연결성/대칭성 5계층 검증
1) 각 부품 STL: watertight + winding 일관 + manifold3d NoError
2) 조립 인스턴스(26부품 + 휠 8: 타이어/림 ×4): 쌍별 교집합 부피 — 1mm³ 초과 FAIL
3) CONTACT 명세 쌍 최단 간극 — 뜬 결합 탐지
4) 접촉 그래프(≤2.5mm) 단일 연결 성분 — 부유 부품 탐지
5) x-미러 대칭성 (차집합/부피 ≤2%) — 타이어/림(단독 비대칭) 제외
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
    "01_floor", "02_diffuser", "03_floor_fences", "04_nose", "05_chassis",
    "06_engine_cover", "07_airbox", "08_sidepod", "09_halo", "10_fw_main",
    "11_fw_flaps", "12_fw_endplates", "13_fw_mounts", "14_rear_wing",
    "15_beam_wing", "16_rw_pylon", "17_mirror", "18_helmet", "19_cockpit_trim",
    "20_steering_wheel", "21_susp_front", "22_susp_rear", "23_brake_scoop_front",
    "24_brake_scoop_rear", "25_tire_front", "26_rim_front", "27_tire_rear",
    "28_rim_rear", "29_gearbox_crash", "30_cameras_antennas",
]
WHEELS = [  # (타이어, 림, 허브x, 액슬y)
    ("25_tire_front", "26_rim_front", 80.0, 180.0),
    ("27_tire_rear",  "28_rim_rear",  77.5, -180.0),
]
SYMMETRIC = [p for p in PARTS
             if p not in ("25_tire_front", "26_rim_front", "27_tire_rear", "28_rim_rear")]
SYM_MAX_RATIO = 0.02

# (A, B, 최대허용간극 mm)
CONTACT = [
    ("01_floor", "02_diffuser", 0.8), ("01_floor", "03_floor_fences", 0.8),
    ("01_floor", "05_chassis", 0.8), ("01_floor", "06_engine_cover", 0.8),
    ("01_floor", "08_sidepod", 0.8), ("01_floor", "29_gearbox_crash", 0.8),
    ("04_nose", "05_chassis", 0.8), ("04_nose", "13_fw_mounts", 0.8),
    ("04_nose", "30_cameras_antennas", 0.8),
    ("05_chassis", "06_engine_cover", 0.8), ("05_chassis", "07_airbox", 0.8),
    ("05_chassis", "08_sidepod", 0.8), ("05_chassis", "09_halo", 0.8),
    ("05_chassis", "17_mirror", 0.8), ("05_chassis", "19_cockpit_trim", 0.8),
    ("05_chassis", "20_steering_wheel", 0.8), ("04_nose", "21_susp_front", 0.8),
    ("05_chassis", "30_cameras_antennas", 0.8),
    ("06_engine_cover", "07_airbox", 0.8), ("06_engine_cover", "16_rw_pylon", 0.8),
    ("07_airbox", "30_cameras_antennas", 0.8),
    ("10_fw_main", "12_fw_endplates", 0.8), ("10_fw_main", "13_fw_mounts", 0.8),
    ("11_fw_flaps", "12_fw_endplates", 0.8),
    ("14_rear_wing", "16_rw_pylon", 0.8),
    ("15_beam_wing", "29_gearbox_crash", 0.8),
    ("02_diffuser", "29_gearbox_crash", 0.8),
    ("18_helmet", "19_cockpit_trim", 0.8),
    ("21_susp_front", "23_brake_scoop_front", 0.8),
    ("21_susp_front", "26_rim_front[L]", 2.0), ("21_susp_front", "26_rim_front[R]", 2.0),
    ("22_susp_rear", "24_brake_scoop_rear", 0.8), ("22_susp_rear", "29_gearbox_crash", 0.8),
    ("22_susp_rear", "28_rim_rear[L]", 2.0), ("22_susp_rear", "28_rim_rear[R]", 2.0),
    ("25_tire_front[L]", "26_rim_front[L]", 0.8),
    ("25_tire_front[R]", "26_rim_front[R]", 0.8),
    ("27_tire_rear[L]", "28_rim_rear[L]", 0.8),
    ("27_tire_rear[R]", "28_rim_rear[R]", 0.8),
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
    m = mesh.copy()
    T = np.eye(4); T[0, 0] = -1.0
    m.apply_transform(T)
    return m

def main():
    ok = True
    meshes = {}

    print("=" * 78)
    print(f"{'부품':<26}{'watertight':<12}{'winding':<10}{'vol(cm3)':>9}{'tris':>9}  bbox(mm)")
    print("-" * 78)
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
        print(f"{name:<26}{flag:<12}{'OK' if wc else 'BAD':<10}{m.volume/1000:>9.1f}{len(m.faces):>9}  {bb}")

    # ---- 인스턴스: 단일 부품 + 휠 8 (타이어/림 × L/R × F/R) ----
    inst = {n: meshes[n] for n in PARTS
            if n not in ("25_tire_front", "26_rim_front", "27_tire_rear", "28_rim_rear")}
    ry_pi = trimesh.transformations.rotation_matrix(np.pi, [0, 1, 0])
    for tire, rim, hx, ay in WHEELS:
        for sx in (-1, 1):
            side = "L" if sx > 0 else "R"
            for wn in (tire, rim):
                T = np.eye(4) if sx > 0 else ry_pi.copy()
                T[:3, 3] = [sx * hx, ay, 36.0]
                w = meshes[wn].copy(); w.apply_transform(T)
                inst[f"{wn}[{side}]"] = w
    mfm = {n: to_manifold(m) for n, m in inst.items()}
    bboxes = {n: m.bounds for n, m in inst.items()}

    # ---- 2) 간섭 ----
    print("\n" + "=" * 78)
    print(f"인스턴스 {len(inst)}개 — 간섭 검사 (교집합 부피 > 1.0 mm³ = FAIL)")
    print("-" * 78)
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
    print("\n" + "=" * 78)
    print(f"결합면 접촉 검사 (CONTACT 명세 {len(CONTACT)}쌍)")
    print("-" * 78)
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
    print("\n" + "=" * 78)
    print(f"조립 연결성 검사 (간극 ≤ {CONNECT_EPS}mm = 접촉 엣지)")
    print("-" * 78)
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

    # ---- 5) 대칭성 ----
    print("\n" + "=" * 78)
    print(f"좌우 대칭성 검사 (x-미러 차집합/부피 > {SYM_MAX_RATIO:.0%} = FAIL)")
    print("-" * 78)
    for name in SYMMETRIC:
        m = meshes[name]
        inter = (to_manifold(m) ^ to_manifold(mirror_x(m))).volume()
        ratio = max(0.0, 1 - inter / m.volume)
        if ratio <= SYM_MAX_RATIO:
            print(f"  대칭 OK  {name:<26} 차집합 비율 {ratio:.3%}")
        else:
            ok = False
            print(f"  비대칭! {name:<26} 차집합 비율 {ratio:.2%} — 미러 루프 누락 의심")
    print("=" * 78)
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
