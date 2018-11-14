clear; close all; clc; dbstop if error;
load('trames.mat'); 
fe = 4e6;
Te = 1/fe;
Ts = 1e-6;
Fse = Ts/Te;

[n,m] = size(trames);
adsb_msgs_test = [];
p=[-0.5*ones(1,Fse/2) 0.5*ones(1,Fse/2)];

for i = 1:m
    % Filtre adapté - Convolution pour obtenir rl(t)
    yl = abs(trames(:,i)');
    rl=conv(yl, fliplr(p));
    % Echantillonnage par Ts pour obtenir rm
    indices = Fse:Fse:length(rl);
    rm=rl(indices);
    % Décision
    decoded_est = rm<0;
    adsb_msgs_test = [adsb_msgs_test ; [decoded_est(9:end)]];
end