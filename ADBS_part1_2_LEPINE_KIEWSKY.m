clear; close all; clc; dbstop if error;

%% D�claration des variables
Nb_fft = 100; % nombre de fenetres
NFFT = 256; % largeur d'une fenetre
N = (Nb_fft+1)*NFFT; % nombre de bits � g�n�rer (pour avoir 100 fenetres de 256 points)
Ts = 1e-6;
fe = 20e6;
Te = 1/fe;
Fse = Ts/Te; % Ts/Te dans m�me unit�s

%% Impl�mentation de la chaine de communication
% Formation du message binaire � construire bk
bk = randi([0,1], N, 1);
Ak = (-2*bk)+1;

% Formation du signal modul� PPM sl(t)
p=[-0.5*ones(1,10) 0.5*ones(1,10)];
upsampled = upsample(Ak, Fse);
sl = 0.5 + conv(upsampled, p);

%% Calcul de la DSP de sl(t)
GammaSl_Welch = Fse*Mon_Welch(sl, NFFT);
f=-1/2:1/NFFT:1/2-1/NFFT;
semilogy(f,GammaSl_Welch)
hold all

%% DSP th�orique
GammaSl_Theo = 0;
semilogy(f, GammaSl_Theo)
legend('DSP pratique', 'DSP th�orique')

%% Restitution des r�sultats
% sl(t) et rl(t)
% time_axis = (0:length(bk)*Fse-1)*Te;
% figure, plot(time_axis, sl)
% title('sl(t)')
% xlabel('Temps (s)')
% ylabel('Amplitude')
% axis([-inf +inf -0.1 1.1])
