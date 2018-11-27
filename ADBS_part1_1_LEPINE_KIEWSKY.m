clear; close all; clc; dbstop if error;

%% D�claration des variables
Ts = 1e-6;
fe = 20e6;
Te = 1/fe;
Fse = Ts/Te; % Ts/Te dans m�me unit�s

%% Impl�mentation de la chaine de communication
% Formation du message binaire � construire bk
bk = [1 0 0 1 0];
% Formation du signal modul� PPM sl(t)
zeros = zeros(1,10);
uns = ones(1,10);
p0=[zeros uns];
p1=[uns zeros];
sl=[p1 p0 p0 p1 p0];
% Formation du filtre biphase p(t)
p=[-0.5*uns 0.5*uns]; % Attention : p(t) et non p*(-t)
% Convolution pour obtenir rl(t)
rl=conv(sl, fliplr(p))*Te;
% Echantillonnage par Ts pour obtenir rm
rm=rl(length(p):Fse:length(bk)*Fse); % d�calage de l'origine due au filtre de mise en forme qui est non causal

%% Restitution des r�sultats
% sl(t) et rl(t)
time_axis = (0:length(bk)*Fse-1)*Te;
figure, subplot(1,2,1), plot(time_axis, sl)
title('sl(t)')
xlabel('Temps (s)')
ylabel('Amplitude')
axis([-inf +inf -0.1 1.1])
time_axis = (0:length(rl)-1)*Te;
subplot(1,2,2), plot(time_axis, rl)
title('rl(t)')
xlabel('Temps (s)')
ylabel('Amplitude')

% Rm
figure, subplot(1,2,1),stairs(rm)
title('rm')

% Bk
bk = rm<0 % d�cision
subplot(1,2,2),scatter(1:length(bk), bk)
title('bk �stim�s')
xlabel('Num�ro du bit')
ylabel('Valeur binaire')
axis([-0.5 length(bk)+1 -0.1 1.1])