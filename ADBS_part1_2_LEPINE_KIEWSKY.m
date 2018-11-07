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
f=[-1/2 : 1/NFFT :1 /2-1/NFFT].*fe;


%% DSP th�orique
dirac_f = dirac(f) == Inf;
GammaSl_Theo = 0.25*dirac_f + ((pi*f).^2*(Ts^3))/16.*(sinc(f*Ts/2)).^4;

%% Restitution des r�sultats
semilogy(f,GammaSl_Welch)
hold all
semilogy(f, GammaSl_Theo)
legend('DSP pratique', 'DSP th�orique')