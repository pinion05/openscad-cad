#!/usr/bin/env python3
"""간섭 진단 — 충돌 쌍의 교집합을 연결 성분으로 분해해 위치/부피 출력"""
import sys, itertools
import numpy as np
import trimesh
import manifold3d

ROOT = __file__.rsplit("/", 2)[0]
STL = f"{ROOT}/stl"
HUB_X, AXLE_Y, WHEEL_R = 800.0, 1150.0, 445.0
SPARE = (0.0, -1420.0, 1048.4 + 160.0)

def to_mf(mesh):
    tri = np.ascontiguousarray(mesh.faces.astype(np.uint32))
    vert = np.ascontiguousarray(mesh.vertices.astype(np.float32))
    return manifold3d.Manifold(manifold3d.Mesh(vert, tri))

def mf_to_tm(mf):
    mesh = mf.to_mesh()
    return trimesh.Trimesh(np.array(mesh.vert_properties), np.array(mesh.tri_verts),
                           process=False)

PARTS = ["01_frame", "02_rollcage", "03_suspension_front", "04_suspension_rear",
         "05_wheel_front", "06_wheel_rear", "07_bodywork", "08_bumper_front",
         "09_bumper_rear", "10_cockpit", "11_drivetrain", "12_lights"]

def build_instances():
    manifolds, meshes = {}, {}
    for n in PARTS:
        m = trimesh.load_mesh(f"{STL}/{n}.stl")
        manifolds[n] = to_mf(m)
        meshes[n] = m
    inst = [(n, manifolds[n]) for n in PARTS if not n.startswith(("05", "06"))]
    for (wn, wy) in [("05_wheel_front", AXLE_Y), ("06_wheel_rear", -AXLE_Y)]:
        for sx in (-1, 1):
            t = trimesh.transformations.rotation_matrix(np.pi/2 * sx, [0, 1, 0])
            t[:3, 3] = [sx * HUB_X, wy, WHEEL_R]
            w = meshes[wn].copy(); w.apply_transform(t)
            inst.append((f"{wn}[{'R' if sx > 0 else 'L'}]", to_mf(w)))
    sp = meshes["06_wheel_rear"].copy(); sp.apply_translation(SPARE)
    inst.append(("06_wheel_rear[SPARE]", to_mf(sp)))
    return inst

def main():
    pairs = sys.argv[1:]
    inst = build_instances()
    d = dict(inst)
    if not pairs:
        # 전체 스캔
        for (a, ma), (b, mb) in itertools.combinations(inst, 2):
            try:
                v = (d[a] ^ d[b]).volume()
            except Exception:
                v = 0
            if v > 1.0:
                pairs.append(f"{a}:{b}")
        pairs = sorted(set(pairs))
    for p in pairs:
        a, b = p.split(":")
        inter = d[a] ^ d[b]
        print(f"\n### {a} <-> {b} : {inter.volume():.1f} mm³")
        tm = mf_to_tm(inter)
        try:
            comps = tm.split(only_watertight=False)
        except Exception:
            comps = [tm]
        comps = sorted(comps, key=lambda c: -abs(c.volume))
        for c in comps[:6]:
            bb = c.bounds
            cx, cy, cz = (bb[0] + bb[1]) / 2
            print(f"   {abs(c.volume):>10.1f} mm³  중심({cx:7.1f},{cy:7.1f},{cz:7.1f})"
                  f"  bbox {bb[1][0]-bb[0][0]:6.1f}x{bb[1][1]-bb[0][1]:6.1f}x{bb[1][2]-bb[0][2]:6.1f}")

if __name__ == "__main__":
    main()
