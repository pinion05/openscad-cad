#!/usr/bin/env python3
"""STL 후처리: 퇴화 면 제거 + 정점 병합 (polyhedron 윙의 LE 근처 0면적 캡 팬 정리)"""
import sys, glob
import numpy as np
import trimesh

def clean(path):
    m = trimesh.load_mesh(path)
    if not isinstance(m, trimesh.Trimesh):
        return False
    # 다중 솔리드 음수 권선(미러본) 교정
    if m.volume < 0 or not m.is_winding_consistent:
        comps = m.split(only_watertight=False)
        fixed = []
        for c in comps:
            if c.volume < 0:
                c.invert()
            fixed.append(c)
        if len(fixed) > 1:
            m = trimesh.util.concatenate(fixed)
            m.export(path)
            print(f"  {path.split('/')[-1]}: 권선 교정 {len(fixed)}솔리드")
    if m.is_watertight:
        return True
    n0 = len(m.faces)
    m.update_faces(m.nondegenerate_faces())
    m.update_faces(m.unique_faces())
    m.remove_unreferenced_vertices()
    m.merge_vertices()
    if len(m.faces) < n0 and m.is_watertight:
        m.export(path)
        print(f"  {path.split('/')[-1]}: {n0} -> {len(m.faces)} faces")
    return m.is_watertight

if __name__ == "__main__":
    targets = sys.argv[1:] or glob.glob("stl/*.stl")
    bad = [t for t in targets if not clean(t)]
    sys.exit(1 if bad else 0)
