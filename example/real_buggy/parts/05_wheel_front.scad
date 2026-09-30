/* 05. 프런트 휠 — 35인치 노브 타이어 + 비드락 림 (타이어+림 일체)
   로컬 축: 휠 축 = +Z (조립 시 ±X 회전 배치), 외경 890mm */
include <../params.scad>
include <../lib.scad>

module part_wheel_front() { wheel(tire_w_f); }

part_wheel_front();
