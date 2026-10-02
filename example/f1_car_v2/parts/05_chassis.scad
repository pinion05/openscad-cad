// 05 샤시(모노코크) — 콕핏 개구 컷 포함
include <../params.scad>
use <../lib.scad>

module chassis()
difference() {
    loftr(CHAS_SEC);
    loftr(CKP_CUT);   // 콕핏 트러프 (y -30..62, 개방 상면)
}

chassis();
