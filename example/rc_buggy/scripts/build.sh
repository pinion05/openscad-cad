#!/bin/bash
# RC 버기 빌드 스크립트 — STL 익스포트 + 렌더링 PNG 생성
set -e
cd "$(dirname "$0")/.."
OSCAD=${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/openscad}
mkdir -p stl render/parts

PARTS="01_chassis 02_rollcage 03_suspension_front 04_suspension_rear \
05_wheel_front 06_wheel_rear 07_bonnet 08_rear_body 09_cockpit \
10_drivetrain 11_bumper_front 12_spoiler"
WARNLOG=build_warnings.log
: > $WARNLOG

echo "== 1) 부품별 STL 익스포트 =="
for p in $PARTS; do
    echo "  stl/$p.stl"
    $OSCAD -o "stl/$p.stl" "parts/$p.scad" 2>>$WARNLOG
done

echo "== 2) 조립 상태 STL (출력용 해상도) =="
$OSCAD -o stl/rc_buggy_assembly.stl assembly.scad 2>>$WARNLOG
echo "  stl/rc_buggy_assembly.stl"
grep -iE 'warning|error' $WARNLOG | grep -v 'Top level' || echo "  (경고 없음)"

echo "== 4) 부품별 렌더링 PNG =="
for p in $PARTS; do
    echo "  render/parts/$p.png"
    $OSCAD -o "render/parts/$p.png" --imgsize=900,700 --autocenter --viewall \
        --camera=0,0,0,60,0,30,0 --colorscheme=Cornfield "parts/$p.scad" 2>/dev/null
done

echo "== 5) 조립 4방향 렌더링 PNG (eye/center 카메라) =="
$OSCAD -o render/assembly_front.png --imgsize=1600,1200 --projection=p \
    --camera=0,1300,66,0,0,66   --colorscheme=Cornfield assembly.scad 2>>$WARNLOG
$OSCAD -o render/assembly_side.png --imgsize=1600,1200 --projection=p \
    --camera=1300,0,66,0,0,66   --colorscheme=Cornfield assembly.scad 2>>$WARNLOG
$OSCAD -o render/assembly_top.png --imgsize=1600,1200 --projection=p \
    --camera=0,0,1500,0,0,66    --colorscheme=Cornfield assembly.scad 2>>$WARNLOG
$OSCAD -o render/assembly_iso.png --imgsize=1600,1200 --projection=p \
    --camera=950,950,750,0,0,66 --colorscheme=Cornfield assembly.scad 2>>$WARNLOG
echo "완료."
