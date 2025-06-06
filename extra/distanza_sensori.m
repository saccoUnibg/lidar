%% calcolo distanza (ottimale per sfruttare la maggior copertura data dal sensore)
clc
clear

theta1 = 3.8; % angolo con maggior copertura sopra l'orizzonte
theta2 = 6.5; % angolo con maggior copertura sotto l'orizzonte

theta1rad = deg2rad(theta1);
theta2rad = deg2rad(theta2);
h = 2.5;

r = h/(sin(theta1rad) + sin(theta2rad))
h1 = r * sin(theta1rad)
h2 = r * sin(theta2rad)
d = r * cos(theta1rad)
