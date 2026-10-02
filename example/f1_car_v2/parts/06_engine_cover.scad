// 06 엔진 커버 — 코크존 테이퍼 + 샤크핀
include <../params.scad>
use <../lib.scad>

module engine_cover() {
    loftr(COV_SEC);
    loftr(FIN_SEC);
}

engine_cover();
