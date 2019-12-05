clc;
clear;
clf;

speed = 55.4214214;
pos = [24,124];

vars = [pos,speed];
str = "Pos: (%.2f,%.2f), Speed: %.3f";
hold on;
ban = Banner(pos,str);
pause(1);
updateBanner(ban,[55,55],vars);
pause(1);
updateBanner(ban,[56,56],vars);
pause(1);
updateBanner(ban,[57,57],vars);