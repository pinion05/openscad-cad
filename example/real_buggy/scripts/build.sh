#!/bin/bash
# 리얼 스케일 버기 빌드 — 부품 STL + 조립 STL + 부품 PNG + 조립 4방향 PNG
set -e
cd "$(dirname "$0")/.."
OSCAD=${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/openscad}

PARTS="01_frame 02_rollcage 03_suspension_front 04_suspension_rear \
05_wheel_front 06_wheel_rear 07_bodywork 08_bumper_front 09_bumper_rear \
10_cockpit 11_drivetrain 12_lights"
ASSEMBLY=assembly
ZC=780
ISO="4500,6100,3700,0,0,$ZC"; FRONT="0,8500,1500,0,0,900"; SIDE="8500,0,1500,0,0,900"; TOP="0,0,8000,0,0,600"

WARNLOG=build_warnings.log
: > $WARNLOG
mkdir -p stl render/parts

echo "== 1) 부품별 STL =="
for p in $PARTS; do
    echo "  stl/$p.stl"
    $OSCAD -o "stl/$p.stl" "parts/$p.scad" 2>>$WARNLOG
done

echo "== 2) 조립 STL =="
$OSCAD -o "stl/${ASSEMBLY}_assembly.stl" "$ASSEMBLY.scad" 2>>$WARNLOG
echo "  stl/${ASSEMBLY}_assembly.stl"
grep -iE 'warning|error' $WARNLOG | grep -v 'Top level' && \
    echo "  !! 경고 발생 — unknown variable 이면 params include 누락" || \
    echo "  (경고 없음)"

echo "== 3) 부품별 PNG =="
for p in $PARTS; do
    $OSCAD -o "render/parts/$p.png" --imgsize=900,700 --autocenter --viewall \
        --camera=0,0,0,60,0,30,0 --colorscheme=Tomorrow "parts/$p.scad" 2>>$WARNLOG
done

echo "== 4) 조립 4방향 PNG =="
for v in iso:$ISO front:$FRONT side:$SIDE top:$TOP; do
    name=${v%%:*}; cam=${v#*:}
    $OSCAD -o "render/assembly_$name.png" --imgsize=1920,1200 --projection=p \
        --camera="$cam" --colorscheme=Tomorrow "$ASSEMBLY.scad" 2>>$WARNLOG
done
echo "완료. 검증: python scripts/validate.py"
