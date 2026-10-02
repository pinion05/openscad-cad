// 11 프런트 윙 플랩 2매 — 센터 중립 구간(|x|<16) 없음: 좌우 반쪽을 별도 로프트
// (하나의 체인으로 이으면 센터를 가로지르는 스트립이 생겨 노우즈와 간섭)
include <../params.scad>
use <../lib.scad>

module fw_flaps() {
    for (h = [FW_F1_HALF, FW_F2_HALF]) {
        wing3(h);
        wing3(msym(h));
    }
}

fw_flaps();
