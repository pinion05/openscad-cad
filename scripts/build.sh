#!/bin/bash
# 파라메트릭 CAD 빌드 — 부품 STL + 조립 STL + 부품/조립 PNG 일괄 생성
# 사용: 프로젝트 루트의 scripts/ 에 두고 PARTS/ASSEMBLY만 편집 후 실행
set -e
cd "$(dirname "$0")/.."
OSCAD=${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/openscad}

# === 프로젝트에 맞게 편집 ===
PARTS="01_part_a 02_part_b 03_part_c"          # parts/ 아래 .scad 파일명(확장자 제외)
ASSEMBLY=assembly                               # 조립 .scad 파일명
# 카메라: eye,center 6값 + 명시적 거리. ZC=모델 중심 높이로 편집
ZC=66
ISO="950,950,750,0,0,$ZC"; FRONT="0,1300,$ZC,0,0,$ZC"; SIDE="1300,0,$ZC,0,0,$ZC"; TOP="0,0,1500,0,0,$ZC"
# ============================

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
    $OSCAD -o "render/parts/$p.png" --imgsize=900,700 --autocenter --viewall \
        --camera=0,0,0,60,0,30,0 --colorscheme=Cornfield "parts/$p.scad" 2>>$WARNLOG
done

echo "== 4) 조립 4방향 PNG =="
for v in iso:$ISO front:$FRONT side:$SIDE top:$TOP; do
    name=${v%%:*}; cam=${v#*:}
    $OSCAD -o "render/assembly_$name.png" --imgsize=1600,1200 --projection=p \
        --camera="$cam" --colorscheme=Cornfield "$ASSEMBLY.scad" 2>>$WARNLOG
done
echo "완료. 검증: .venv/bin/python scripts/validate.py"
