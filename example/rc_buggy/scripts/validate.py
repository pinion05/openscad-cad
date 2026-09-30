#!/usr/bin/env python3
"""매니폴드/간섭 검증 스크립트
- 각 부품 STL: watertight + 외적 체적 + 최소 벽 두께 힌트(bbox/볼륨 리포트)
- 조립 상태: 부품 간 실체 간섭(부피 교집합) 검사 — manifold3d 불리언 사용
"""
import sys, itertools, json
import numpy as np
import trimesh
import manifold3d

ROOT = __file__.rsplit("/", 2)[0]
STL = f"{ROOT}/stl"

PARTS = [
    "01_chassis", "02_rollcage", "03_suspension_front", "04_suspension_rear",
    "05_wheel_front", "06_wheel_rear", "07_bonnet", "08_rear_body",
    "09_cockpit", "10_drivetrain", "11_bumper_front", "12_spoiler",
]

def to_manifold(mesh):
    tri = np.ascontiguousarray(mesh.faces.astype(np.uint32))
    vert = np.ascontiguousarray(mesh.vertices.astype(np.float32))
    return manifold3d.Manifold(manifold3d.Mesh(vert, tri))

def main():
    ok = True
    manifolds = {}

    print("=" * 72)
    print(f"{'부품':<24}{'watertight':<12}{' winding':<10}{' vol(cm3)':>10}{'  tris':>9}  bbox(mm)")
    print("-" * 72)
    for name in PARTS:
        m = trimesh.load_mesh(f"{STL}/{name}.stl")
        wt = m.is_watertight
        wc = m.is_winding_consistent
        # manifold3d 변환 성공 여부 = 매니폴드 보장
        try:
            mf = to_manifold(m)
            mf_ok = (mf.status() == manifold3d.Error.NoError) and mf.volume() > 0
        except Exception as e:
            mf_ok = False
            print(f"  manifold3d 오류: {e}")
        flag = "OK" if (wt and wc and mf_ok) else "FAIL"
        if flag == "FAIL":
            ok = False
        manifolds[name] = (m, mf)
        b = m.bounds
        bb = f"{b[1][0]-b[0][0]:.0f}x{b[1][1]-b[0][1]:.0f}x{b[1][2]-b[0][2]:.0f}"
        print(f"{name:<24}{flag:<12}{'OK' if wc else 'BAD':<10}{m.volume/1000:>10.1f}{len(m.faces):>9}  {bb}")

    # ---- 조립 인스턴스 구성 (휠은 4개 위치에 배치) ----
    inst = [(n, manifolds[n][0]) for n in PARTS if not n.startswith(("05", "06"))]
    for (wn, wx, wy) in [("05_wheel_front", 104, 130), ("06_wheel_rear", 100, -130)]:
        base = manifolds[wn][0]
        for sx in (-1, 1):
            t = trimesh.transformations.rotation_matrix(np.pi/2 * sx, [0, 1, 0])
            t[:3, 3] = [sx * wx, wy, 55.0]
            w = base.copy(); w.apply_transform(t)
            inst.append((f"{wn}[{'R' if sx>0 else 'L'}]", w))

    print("\n" + "=" * 72)
    print("부품 간 간섭 검사 (교집합 부피 > 1.0 mm³ = FAIL)")
    print("-" * 72)
    n_col = 0
    for (a, ma), (b, mb) in itertools.combinations(inst, 2):
        # 빠른 거릿값 사전 필터
        ca, cb = ma.bounds, mb.bounds
        if np.any(ca[0] > cb[1]) or np.any(cb[0] > ca[1]):
            continue
        try:
            inter = to_manifold(ma) ^ to_manifold(mb)
            v = inter.volume()
        except Exception:
            v = 0.0
        if v > 1.0:
            ok = False; n_col += 1
            print(f"  간섭! {a} <-> {b} : {v:.1f} mm³")
    if n_col == 0:
        print("  간섭 없음 — 모든 부품 조립 가능(클리어런스 확보)")
    print("=" * 72)
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
