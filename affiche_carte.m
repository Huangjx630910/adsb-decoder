clear 
close all
clc

REF_LON = -0.606629;
REF_LAT = 44.806884;

figure(1);
x = linspace(-1.3581,0.7128,1024);
y = linspace(44.4542,45.1683,1024);
im = imread('fond.png');
image(x,y(end:-1:1),im);
hold on
plot(REF_LON,REF_LAT,'.r','MarkerSize',20);
text(REF_LON+0.05,REF_LAT,'Actual pos','color','b')
set(gca,'YDir','normal')

xlabel('Longitude en degres');
ylabel('Lattitude en degres');