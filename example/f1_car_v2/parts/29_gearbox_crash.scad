// 29 기어박스 + 리어 크래시 구조 — 테이퍼 블록 + 서스펜션 타워 + 레인 라이트
include <../params.scad>
use <../lib.scad>

module gearbox_crash() {
    loftr(GEAR_SEC);
    // 서스펜션 타워 ±(어퍼 위시본 픽업, 기부는 기어박스에 매립) — r은 dx/2 미만
    for (s = [-1, 1]) rbox(s * 9.65, -179, 21, 50, 3.3, 42, 1.5);
    // 레인 라이트 포드 (테일 단부)
    rbox(0, -256.8, 12, 16, RAIN_LT[1], 1.2, 0.5);
}

gearbox_crash();
