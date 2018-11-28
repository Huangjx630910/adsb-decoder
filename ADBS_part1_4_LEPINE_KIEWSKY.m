clear; close all; clc; dbstop if error;

%% D�claration des variables
N = 88; % nombre de bits d'information
Ts = 1e-6;
fe = 20e6;
Te = 1/fe;
Fse = Ts/Te; % Ts/Te dans m�me unit�s

%% Impl�mentation de la chaine de communication
% Encodage CRC
bk = randi([0,1], N, 1);
crc_poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
generateur = crc.generator(crc_poly);
encoded = generate(generateur, bk);

% Formation du message binaire de symboles Ak
Ak = (-2*encoded)+1;

% Formation du signal modul� PPM sl(t)
p=[-0.5*ones(1,10) 0.5*ones(1,10)];
upsampled = upsample(encoded, Fse);
sl = 0.5 + conv(upsampled, p);
retard_introduit = 19;
yl = sl(1:end-retard_introduit);

% Filtre adapt� - Convolution pour obtenir rl(t)
rl=conv(yl, fliplr(p))*Te;

% Echantillonnage par Ts pour obtenir rm
rm=rl(length(p):Fse:length(Ak)*Fse)/Te;

% D�cision
decoded_est = rm>0;

% Introduction d'une erreur (� d�commenter)
%decoded_est(1) = ~decoded_est(1);

% D�codage CRC
detecteur = crc.detector(crc_poly);
[decoded error] = detect(detecteur, decoded_est);

%% Restitution des r�sultats
error