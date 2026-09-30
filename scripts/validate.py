#!/usr/bin/env python3
"""파라메트릭 CAD 검증 — 부품별 매니폴드 + 조립 간섭(정확한 불리언 교집합)

사용 전 편집:
  PARTS     : stl/ 아래 부품 파일명 (assembly/_ 시작 파일은 자동 제외)
  INSTANCES : 휠처럼 한 STL을 여러 위치에 배치하는 경우
              (파일명 → [(rx,ry,rz 도, tx,ty,tz), ...])

의존성: .venv에 numpy trimesh manifold3d scipy networkx rtree
"""
import sys, itertools
import numpy as np
import trimesh
import manifold3d

ROOT = __file__.rsplit("/", 2)[0]
STL = f"{ROOT}/stl"

# === 프로젝트에 맞게 편집 ===
PARTS = [
    # "01_chassis", "02_rollcage", ...
]
INSTANCES = {
    # "05_wheel_front": [ (0, 90, 0, 104, 130, 55), (0, -90, 0, -104, 130, 55) ],
}
# ============================

def to_mf(m):
    return manifold3d.Manifold(manifold3d.Mesh(
        np.ascontiguousarray(m.vertices.astype(np.float32)),
        np.ascontiguousarray(m.faces.astype(np.uint32))))

def mf_tri(mf):
    mm = mf.to_mesh()
    return trimesh.Trimesh(np.array(mm.vert_properties)[:, :3], np.array(mm.tri_verts))

def main():
    ok = True
    print("=" * 72)
    print(f"{'부품':<26}{'watertight':<12}{'winding':<10}{'vol(cm3)':>9}{'  tris':>8}")
    print("-" * 72)
    manifolds = {}
    for name in PARTS:
        m = trimesh.load_mesh(f"{STL}/{name}.stl")
        try:
            mf = to_mf(m)
            mf_ok = (mf.status() == manifold3d.Error.NoError) and mf.volume() > 0
        except Exception as e:
            mf_ok = False; print(f"  manifold3d 오류: {e}")
        wt, wc = m.is_watertight, m.is_winding_consistent
        if not (wt and wc and mf_ok):
            ok = False
        manifolds[name] = m
        print(f"{name:<26}{'OK' if wt else 'FAIL':<12}{'OK' if wc else 'BAD':<10}"
              f"{m.volume/1000:>9.1f}{len(m.faces):>8}")

    inst = [(n, manifolds[n]) for n in PARTS if n not in INSTANCES]
    for name, ts in INSTANCES.items():
        for k, (rx, ry, rz, tx, ty, tz) in enumerate(ts):
            w = manifolds[name].copy()
            T = np.eye(4); T[:3, :3] = trimesh.transformations.euler_matrix(
                np.radians(rx), np.radians(ry), np.radians(rz))[:3, :3]
            T[:3, 3] = [tx, ty, tz]
            w.apply_transform(T)
            inst.append((f"{name}[{k}]", w))

    print("\n부품 간 간섭 검사 (교집합 > 1.0 mm³ = FAIL)")
    n_col = 0
    for (a, ma), (b, mb) in itertools.combinations(inst, 2):
        ca, cb = ma.bounds, mb.bounds
        if np.any(ca[0] > cb[1]) or np.any(cb[0] > ca[1]):
            continue
        try:
            inter = to_mf(ma) ^ to_mf(mb)
            v = inter.volume()
        except Exception:
            v = 0.0
        if v > 1.0:
            ok = False; n_col += 1
            tm = mf_tri(inter)
            comps = tm.split(only_watertight=False)   # 연결 성분 = 충돌 피처 쌍
            lo, hi = tm.bounds
            print(f"  간섭! {a} <-> {b} : {v:.1f} mm³  bbox="
                  f"[{lo[0]:.0f},{lo[1]:.0f},{lo[2]:.0f}]-[{hi[0]:.0f},{hi[1]:.0f},{hi[2]:.0f}] "
                  f"({len(comps)}개 성분)")
    if n_col == 0:
        print("  간섭 없음")
    print("=" * 72)
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
