// 19 콕핏 트림 — 시트 쿠션 + 헤드레스트 링 (헬멧 허깅)
include <../params.scad>
use <../lib.scad>

module cockpit_trim() {
    loftr(SEAT_SEC);
    difference() {
        loftr(HREST_SEC);
        translate(HELM_C) scale(HELM_SC) sphere(HELM_R + 0.4, $fn = 64);
    }
}

cockpit_trim();
