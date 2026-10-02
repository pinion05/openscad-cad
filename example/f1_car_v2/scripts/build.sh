#!/bin/bash
# F1 1:10 v2 빌드 — 30부품 STL + 조립 STL + 부품/조립 PNG
set -e
cd "$(dirname "$0")/.."
OSCAD=${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/openscad}

PARTS="01_floor 02_diffuser 03_floor_fences 04_nose 05_chassis 06_engine_cover 07_airbox 08_sidepod 09_halo 10_fw_main 11_fw_flaps 12_fw_endplates 13_fw_mounts 14_rear_wing 15_beam_wing 16_rw_pylon 17_mirror 18_helmet 19_cockpit_trim 20_steering_wheel 21_susp_front 22_susp_rear 23_brake_scoop_front 24_brake_scoop_rear 25_tire_front 26_rim_front 27_tire_rear 28_rim_rear 29_gearbox_crash 30_cameras_antennas"
ASSEMBLY=assembly
ZC=40
ISO="950,950,700,0,10,$ZC"; FRONT="0,1250,$ZC,0,10,$ZC"; SIDE="1250,0,$ZC,0,10,$ZC"; TOP="0,0,1450,0,10,$ZC"

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
    echo "  !! 경고 발생 — unknown variable 이면 params include 누락(함정 1)" || \
    echo "  (경고 없음)"

echo "== 3) 부품별 PNG =="
for p in $PARTS; do
    $OSCAD -o "render/parts/$p.png" --imgsize=1200,900 --autocenter --viewall \
        --camera=0,0,0,60,0,30,0 --colorscheme=Cornfield "parts/$p.scad" 2>>$WARNLOG
done

echo "== 4) 조립 4방향 PNG =="
for v in iso:$ISO front:$FRONT side:$SIDE top:$TOP; do
    name=${v%%:*}; cam=${v#*:}
    $OSCAD -o "render/assembly_$name.png" --imgsize=1920,1200 --projection=p \
        --camera="$cam" --colorscheme=Cornfield "$ASSEMBLY.scad" 2>>$WARNLOG
done
echo "완료. 검증: .venv/bin/python scripts/validate.py"
