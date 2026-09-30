/* 06. 리어 휠 — 프런트와 동일 설계, 폭만 와이드(50mm). 전후 비대칭 스탠스
   (use 는 변수를 가져오지 않으므로 params 를 직접 include) */
include <../params.scad>
use <05_wheel_front.scad>

module part_wheel_rear() { wheel(tire_w_r); }

part_wheel_rear();
