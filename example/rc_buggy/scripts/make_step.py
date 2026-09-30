#!/usr/bin/env python3
"""조립 상태 STL → STEP 변환 (OCP 직접 사용 — cadquery 2.8은 importStl 미제공)
입력: stl/rc_buggy_assembly.stl → step/rc_buggy_assembly.step
메시 삼각형별 페이스로 구성된 페이싯 BREP STEP (약 14만 페이스, ~24MB, 4~5분)."""
import sys, time
from OCP.RWStl import RWStl
from OCP.BRep import BRep_Builder
from OCP.TopoDS import TopoDS_Compound
from OCP.BRepBuilderAPI import BRepBuilderAPI_MakeFace, BRepBuilderAPI_MakePolygon
from OCP.STEPControl import STEPControl_Writer, STEPControl_StepModelType
from OCP.Interface import Interface_Static

ROOT = __file__.rsplit("/", 2)[0]
src = f"{ROOT}/stl/rc_buggy_assembly.stl"
dst = f"{ROOT}/step/rc_buggy_assembly.step"

t0 = time.time()
print(f"STL 로드: {src}")
tri = RWStl.ReadFile_s(src)
# 노드는 tri.Node(i) 로 직접 접근
nt = tri.NbTriangles()
print(f"삼각형 {nt}개 → 페이스 빌드 중...")

builder = BRep_Builder()
comp = TopoDS_Compound()
builder.MakeCompound(comp)
for i in range(1, nt + 1):
    a, b, c = tri.Triangle(i).Get()
    poly = BRepBuilderAPI_MakePolygon(tri.Node(a), tri.Node(b), tri.Node(c), True)
    face = BRepBuilderAPI_MakeFace(poly.Wire())
    builder.Add(comp, face.Face())
    if i % 2000 == 0:
        print(f"  {i}/{nt} ({time.time()-t0:.0f}초)", flush=True)

print("STEP 작성 중...")
Interface_Static.SetCVal_s("write.step.schema", "AP214IS")
w = STEPControl_Writer()
w.Transfer(comp, STEPControl_StepModelType.STEPControl_AsIs)
w.Write(dst)
print(f"완료: {dst}  ({time.time()-t0:.0f}초)")
