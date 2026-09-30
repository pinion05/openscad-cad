/* 07. 보닛(프런트 바디) — 코웰에서 라디에이터 위로 내려가는 좁은 쐐기형 노즈
   좌우 쇼크 타워/스프링은 노출(샌드레일 스타일) */
include <../params.scad>
include <../lib.scad>

module part_bonnet() {
    hull() {
        translate([0,  58, 92]) cube([80, 4, 8],  center = true);  // 코웰 상단
        translate([0, 150, 74]) cube([68, 4, 8],  center = true);  // 미드
        translate([0, 168, 62]) cube([60, 4, 8],  center = true);  // 노즈 팁
    }
}

part_bonnet();
