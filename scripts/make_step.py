#!/usr/bin/env python3
"""조립 STL → STEP 변환 (OCP 직접 사용 — cadquery 2.8은 importStl 미제공)

사용: .venv/bin/python scripts/make_step.py stl/xxx_assembly.stl
결과: step/xxx_assembly.step — 메시 삼각형별 페이스의 페이싯 BREP
      (~14만 삼각형 기준 4~5분, ~24MB). 뷰어/검토용이며 편집용이 아님.

의존성: .venv에 cadquery(OCP 포함)
"""
import sys, os, time
from OCP.RWStl import RWStl
from OCP.BRep import BRep_Builder
from OCP.TopoDS import TopoDS_Compound
from OCP.BRepBuilderAPI import BRepBuilderAPI_MakeFace, BRepBuilderAPI_MakePolygon
from OCP.STEPControl import STEPControl_Writer, STEPControl_StepModelType
from OCP.Interface import Interface_Static

src = sys.argv[1] if len(sys.argv) > 1 else "stl/assembly_assembly.stl"
dst = sys.argv[2] if len(sys.argv) > 2 else \
    f"step/{os.path.splitext(os.path.basename(src))[0]}.step"
os.makedirs(os.path.dirname(dst), exist_ok=True)

t0 = time.time()
print(f"STL 로드: {src}")
tri = RWStl.ReadFile_s(src)
nt = tri.NbTriangles()
print(f"삼각형 {nt}개 → 페이스 빌드 중...")

builder = BRep_Builder()
comp = TopoDS_Compound()
builder.MakeCompound(comp)
for i in range(1, nt + 1):
    a, b, c = tri.Triangle(i).Get()
    poly = BRepBuilderAPI_MakePolygon(tri.Node(a), tri.Node(b), tri.Node(c), True)
    builder.Add(comp, BRepBuilderAPI_MakeFace(poly.Wire()).Face())
    if i % 5000 == 0:
        print(f"  {i}/{nt} ({time.time()-t0:.0f}초)", flush=True)

print("STEP 작성 중...")
Interface_Static.SetCVal_s("write.step.schema", "AP214IS")
w = STEPControl_Writer()
w.Transfer(comp, STEPControl_StepModelType.STEPControl_AsIs)
w.Write(dst)
print(f"완료: {dst}  ({time.time()-t0:.0f}초)")
