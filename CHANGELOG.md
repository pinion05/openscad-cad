# Changelog

## 0.1.1 (2026-09-30)

- 함정 카탈로그 4종 추가(10~13) — 1:1 실차 버기 제작에서 실측 사례:
  - 미러 루프의 X축 실린더/좌표 미러링(`rotate([0,s*90,0])`, `mir(p,s)`) —
    좌측 부품 누락·역방향 스텁 관통 사고
  - 절단 큐브는 대상 두께 전체 관통(center=true + 양측 돌출)
  - `offset(r)`의 외팽창이 인접 발판 간격을 침식
  - Y축 실린더 회전 부호(`[90,0,0]`→−Y / `[-90,0,0]`→+Y)
- manifold3d `Manifold.bounds` 부재 API 노트 추가(함정 8)
- SKILL.md: lib 스니펫에 `mir()` 헬퍼 추가, 함정 요약 8~11, 예제 안내 갱신
- example/real_buggy: 1:1 리얼 스케일 버기 예제 추가(12부품, 6라운드 검증,
  간섭 0mm³, 진단 스크립트 diagnose.py 포함)

## 0.1.0 (2026-09-30)

- 초기 릴리스
- SKILL.md: 설계→빌드→매니폴드/간섭 검증→렌더링→STEP 워크플로
- references/pitfalls.md: 실전 함정 카탈로그 9종
- scripts/: build.sh / validate.py / make_step.py 범용 템플릿
- example/rc_buggy: 1:10 RC 오프로드 버기 검증 예제 (12부품, 간섭 0mm³)
