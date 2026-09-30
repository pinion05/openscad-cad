---
name: openscad-cad
version: 0.1.1
description: OpenSCAD CLI로 파라메트릭 3D 부품/조립 모델을 설계·빌드·검증하는 워크플로. 부품별 .scad 분리, STL/STEP 익스포트, 매니폴드·부품 간 간섭 자동 검증(manifold3d 불리언), 헤드리스 PNG 렌더링 포함. 이 머신(macOS)에서 검증된 OpenSCAD 경로·Python venv 구성과, 실전에서 직접 밟은 함정(use/include, center=true, -D 한계 등)의 해법이 내장되어 있다. 트리거 — OpenSCAD, 파라메트릭 CAD, 3D 프린팅 부품 모델링/설계, STL/STEP 뽑기, 조립형 모델, 부품 간섭/간섭 검사, 매니폴드/watertight 검증, RC카·프레임·케이지 같은 출력물 설계, "CAD 스크립트로 만들어줘".
---

# OpenSCAD CLI 파라메트릭 CAD

버전 0.1.0 (프론트매터 `version` 필드와 항상 일치시킬 것)

## 언제 이 스킬을 쓰나

CLI로 3D 프린팅 가능한 부품/조립 모델을 만들 때. 특히 여러 부품이 클리어런스를
유지하며 조립되어야 하고, 치수를 한 곳에서 일괄 수정해야 하며, 매니폴드와 간섭
검증이 필요한 작업(예: RC카, 기구물, 케이스, 지그). 형상이 단순하면 OpenSCAD 하나로
설계→STL→STEP→렌더링→검증까지 전부 커버된다.

## 0단계 — 환경 확인 (이 머신 기준)

```bash
# OpenSCAD: CLI가 PATH에 없다. 앱 번들 내부 경로를 쓴다 (헤드리스 PNG 렌더링 정상 동작 확인됨)
OSCAD=/Applications/OpenSCAD.app/Contents/MacOS/openscad
$OSCAD --version

# 검증/변환용 Python (homebrew 3.12 + venv)
/opt/homebrew/bin/python3.12 -m venv .venv
.venv/bin/pip install numpy trimesh manifold3d scipy networkx rtree
# STEP 변환만 필요하면 OCP가 필요하므로 cadquery도 설치 (무겁다, ~150MB)
.venv/bin/pip install cadquery
```

- trimesh의 `contains()`는 rtree, `split()`은 scipy+networkx가 없으면 죽는다. 처음에 전부 설치할 것.
- cadquery 2.8은 `importers.importStl`이 없다. STL→STEP은 `scripts/make_step.py`(OCP 직접 사용)로.

## 표준 프로젝트 구조

```
project/
├── params.scad        ★ 모든 주요 치수 (유일한 수정 지점)
├── lib.scad           공용 프리미티브 (rod/orient/plate/coil...)
├── parts/NN_name.scad 부품별 파일 — 마지막 줄에 `part_name();` 넣어 단독 익스포트 가능
├── assembly.scad      use <parts/...> 로 조립 + color 배치
├── stl/  render/  step/
└── scripts/
    ├── build.sh       STL+PNG 일괄 생성 (이 스킬 `scripts/build.sh`을 복사해 PARTS만 편집)
    ├── validate.py    매니폴드+간섭 검증 (`scripts/validate.py`을 복사해 INSTANCES만 편집)
    └── make_step.py   조립 STL → STEP
```

**핵심 규약** — 부품 파일과 assembly는 반드시 `include <params.scad>`를 직접 할 것.
`use`는 모듈만 가져오고 **변수를 가져오지 않는다** (최대 사고 원인, 아래 함정 1).

## 워크플로 (반복 사이클)

1. **좌표 예산표 먼저**: 축별로 존(zone)과 통로(corridor)를 표로 정리한다. 예: Y축에
   범퍼/액슬/보닛/콕핏/엔진/윙 순으로 구간을, X축에 "바디 폭 | 호스·암 통로 | 휠"처럼
   통로를 예약한다. 나중에 호스나 암이 패널을 뚫는 간섭은 대부분 통로 미예약 때문이다.
2. **params.scad 작성** → lib.scad 작성 (핵심 헬퍼는 아래 스니펫).
3. **부품 파일 작성** — 한 부품씩 만들고 그때그때 `openscad -o`로 확인.
4. **build.sh + validate.py** 을 돌리고, 간섭이 잡힐 때마다 고치고 재검증. 검증 통과가 곧 완료 기준.
5. 렌더링 4방향 + STEP으로 마무리.

### lib.scad 핵심 스니펫 (검증된 버전)

```scad
// 두 점을 잇는 캡슐 튜브 — 끝단이 od/2 만큼 뻗는다(함정 3)
module rod(p1, p2, od, fn=48)
    hull() { translate(p1) sphere(d=od, $fn=fn); translate(p2) sphere(d=od, $fn=fn); }

// 로컬 +Z를 p1→p2 방향으로. 순서가 틀리면 축이 XZ평면에 갇힌다(함정 4)
module orient(p1, p2) {
    v = p2 - p1;  h = norm([v.x, v.y]);
    translate(p1)
        rotate([0, 0, atan2(v.y, v.x)])
        rotate([0, atan2(h, v.z), 0])
        children();
}

// 모서리 둥근 수직판. y1<y0 같은 음수 길이를 넣지 말 것(함정 6)
module plate(x, y, z0, z1, r=4, fn=32)
    hull() for (px=[-1,1], py=[-1,1])
        translate([px*(x/2-r), py*(y/2-r), z0]) cylinder(r=r, h=z1-z0, $fn=fn);
```

### 부품 간 클리어런스 규약

- 결합면(볼트/안착면)은 **0.4mm** 간극이 기본값. 맞춤(프레스핏)이 필요하면 0.2mm.
- 캡슐 튜브가 다른 부품과 만나는 끝단은 반지름만큼 더 띄운다.
- 매번 손계산하지 말고 validate.py에 맡긴다(아래).

## 검증 — 이 스킬의 핵심

`scripts/validate.py`를 프로젝트에 복사하고 상단 `PARTS`/`INSTANCES`(휠처럼 여러
위치에 배치되는 부품)만 편집한다:

```bash
.venv/bin/python scripts/validate.py
```

- 부품별: watertight + winding 일관 + manifold3d 변환 NoError + 부피/삼각형 수
- 조립: 모든 인스턴스 쌍의 **정확한 불리언 교집합 부피** — 1mm³ 초과면 FAIL

간섭이 잡히면 추측하지 말고 교집합을 분해해 본다 (진단의 정석):

```python
inter = to_mf(a) ^ to_mf(b)          # 교집합 manifold
tm = mf_to_trimesh(inter)
comps = tm.split(only_watertight=False)   # 연결 성분 = 충돌 피처 쌍과 1:1
# 각 성분의 volume + bounds 를 보면 "무엇을 어디로 옮겨야 하는지"가 바로 나온다
```

레벨별 진단 순서: ① 교집합 bbox → ② 연결 성분 분리 → ③ 의심 프리미티브만 분리
익스포트해 포인트 프로브(`mesh.contains`). 부품 내부 의도된 합체(용접 조인트)는
검증에서 제외되지 않으니, 같은 부품 내 중첩은 설계대로 무시한다.

## 렌더링 (헤드리스 PNG)

카메라는 **eye/center 6값 형식 + 명시적 거리**가 제일 안정적이다. `--viewall`은
방향을 무시하고 재조정하는 경우가 있어 함정(함정 7).

```bash
$OSCAD -o out.png --imgsize=1600,1200 --projection=p \
    --camera=950,950,750,0,0,66 --colorscheme=Cornfield assembly.scad
# eye=(950,950,750), center=(0,0,66) → 아이소메트릭
# 정면: 0,1300,Z,0,0,Z / 측면: 1300,0,Z,0,0,Z / 상면: 0,0,1500,0,0,Z
# 부품 단독: --autocenter --viewall --camera=0,0,0,60,0,30,0 (gimbal 형식은 부품용으로만)
```

## STEP 익스포트

`scripts/make_step.py`: 조립 STL → 페이싯 BREP STEP (OCP 직접 변환).
~14만 삼각형 기준 약 4~5분, ~24MB. 검토·뷰어용으로 충분하며, 편집 가능한
진짜 파라메트릭 STEP이 필요하면 처음부터 CadQuery/Build123D로 모델링해야 한다.
OCP API 노트: 정적 메서드는 `_s` 접미사(`RWStl.ReadFile_s`), 삼각형/정점은
`tri.Triangle(i).Get()` / `tri.Node(i)`.

## 함정 요약 (상세는 references/pitfalls.md 읽을 것)

1. `use`는 변수 미전달 → 모든 파일에서 `include <params.scad>` 직접. undef 형상은 조용히 무너진다.
2. 실린더 `center=true` 누락 → 보어/컷이 한쪽만 파인다. 대칭 컷은 항상 점검.
3. 캡슐 끝단은 od/2 초과 뻗음 → 부품 경계 클리어런스는 반지름만큼 가산.
4. orient() 회전 순서 → 외부 Z, 내부 Y 순서만 정답.
5. `-D` 오버라이드는 include/use 체인을 못 넘는다 → 전역 해상도는 루트 `$fn` 하나로.
6. 파라미터는 앞/뒤 명명으로 길이 항상 양수화.
7. 빌드 로그에서 stderr를 버리지 않는다("unknown variable" 경고 = 실버그).
8. 미러 루프 안 X축 실린더는 `rotate([0, s*90, 0])`, 좌표는 `mir(p,s)`(함정 10).
   좌측 부품 누락은 validate가 못 잡는다 — 대칭성 프로브로 확인.
9. 절단 큐브는 대상 두께 전체 관통(center=true + slab 중심 + 양측 돌출).
10. `offset(r)`은 도형을 r만큼 바깥으로 팽창 — 인접 간격 계산에 반영.
11. `rotate([90,0,0])`은 +Z→−Y. +Y 확장은 `[-90,0,0]`(함정 13).

## 검증된 전체 예제

`example/rc_buggy/` (깃허브 레포 참조): 1:10 RC 오프로드 버기 — 12부품,
매니폴드 전부 통과 + 간섭 0mm³. params/lib/parts/assembly/scripts 전체가
이 스킬의 템플릿 그대로다. 새 프로젝트는 이 구조를 복사해 시작하는 게 빠르다.
`example/real_buggy/`: 1:1 실차 스케일 버기(전장 3,400mm·35인치 타이어) — 같은
템플릿으로 6라운드 검증 끝에 간섭 0mm³. 미러링/컷 큐브/offset 함정(10~12)의
실제 사례 수치와 `scripts/diagnose.py`(간섭 연결 성분 분해)가 들어 있다.
