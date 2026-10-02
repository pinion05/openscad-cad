#!/usr/bin/env python3
"""간섭 진단 — 두 부품의 불리언 교집합을 연결 성분으로 분해해 피처 지목"""
import sys
import numpy as np
import trimesh
import manifold3d

ROOT = __file__.rsplit("/", 2)[0]
STL = f"{ROOT}/stl"

def to_mf(mesh):
    tri = np.ascontiguousarray(mesh.faces.astype(np.uint32))
    vert = np.ascontiguousarray(mesh.vertices.astype(np.float32))
    return manifold3d.Manifold(manifold3d.Mesh(vert, tri))

def mf_to_tm(mf):
    mesh = mf.to_mesh()
    return trimesh.Trimesh(vertices=np.array(mesh.vert_properties),
                           faces=np.array(mesh.tri_verts), process=False)

def main(a, b):
    ma = trimesh.load_mesh(f"{STL}/{a}.stl")
    mb = trimesh.load_mesh(f"{STL}/{b}.stl")
    inter = to_mf(ma) ^ to_mf(mb)
    tm = mf_to_tm(inter)
    print(f"{a} <-> {b} : 교집합 {inter.volume():.2f} mm³, tris {len(tm.faces)}")
    comps = tm.split(only_watertight=False)
    for i, c in enumerate(sorted(comps, key=lambda m: -m.volume)):
        b0, b1 = c.bounds
        bb = f"x[{b0[0]:.1f},{b1[0]:.1f}] y[{b0[1]:.1f},{b1[1]:.1f}] z[{b0[2]:.1f},{b1[2]:.1f}]"
        print(f"  성분{i}: vol {float(c.volume):.2f} mm³  {bb}")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
