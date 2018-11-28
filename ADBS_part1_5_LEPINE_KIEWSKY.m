clear; close all; clc; dbstop if error;

%% Déclaration des variables
N = 88; % Nombre de bits d'information
Ts = 1e-6;
Tp = 8*Ts;
fe = 20e6;
Te = 1/fe;
Fse = Ts/Te; % Ts/Te dans même unité

%% Encodage CRC
bk = randi([0,1], N, 1);
crc_poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
generateur = crc.generator(crc_poly);
encoded = generate(generateur, bk);

%% Signal sl
% Formation du message binaire de symboles Ak
Ak = (-2*encoded)+1;

% Formation du signal modulé PPM sl(t)
p=[-0.5*ones(1,10) 0.5*ones(1,10)];
upsampled = upsample(encoded, Fse);
sl = 0.5 + conv(upsampled, p);
retard_introduit = 19;
sl = sl(1:end-retard_introduit);
sl=sl';

%% Simulation du signal recu (utile pour vérification de delta_t)

% Ajout du préambule 
one=ones(1,10);
zero=zeros(1,10);
sp=[1 0  0 one zero one zeros(1,40) one zero one zeros(1,60)];
sl=[sp sl];

% Ajout d'un retard aléatoire 
delta_t_avion = floor(100*rand(1))
sl_retard = [randi([0 1],1,delta_t_avion) sl];

%Génération du bruit
sigma2=1; % A verif
nl=0; % sans bruit pour le test

% Ajout du bruit
yl_retard = sl_retard+nl; 


%% Synchronisation 

% Retard delta_t
liste_delta_t=[0:100];

% rl
zl=0; % Sans bruit pour le moment 
rl=sl_retard+zl;

% Estimation de delta_t
est_delta_t = synchronisation(rl, sp, liste_delta_t, Tp/Ts, Te, Fse) 

% Synchronisation en temps du signal recu sans le préambule
yl=yl_retard(1,est_delta_t+length(sp)+1:end); 
yl=yl';

%% Signal rl et rm
% Filtre adapté - Convolution pour obtenir rl(t)
rl=conv(yl, fliplr(p))*Te;

% Echantillonnage par Ts pour obtenir 
rm=rl(length(p):Fse:length(Ak)*Fse)/Te;

%% Décision
decoded_est = rm>0;

%% Décodage CRC

detecteur = crc.detector(crc_poly);
[decoded error] = detect(detecteur, decoded_est);


%% Restitution des résultats
error