clear; close all; clc; dbstop if error;

%% Déclaration des variables
Nb = 1000; % Taille paquet binaire 
Ts = 1e-6;
fe = 20e6;
Te = 1/fe;
Fse = Ts/Te; % Ts/Te dans même unités  
TEB=[];

% Filtre de mise en forme
p=[-0.5*ones(1,10) 0.5*ones(1,10)];
        
 % RSB
RSB_db=[0:1:10];
RSB = 10.^(RSB_db/10); %Eb/N0
sigmas2 = sum(abs(p.^2))./(2*RSB); % Variance du bruit

%% Implémentation de la chaine de communication

% Bits générés aléatiorement suivant la loi uniforme
bk = randi([0,1], Nb, 1);

% Génération de la séquence symbole
Ak = (-2*bk)+1;

% Formation du signal modulé PPM sl(t)
upsampled = upsample(Ak, Fse);
sl = 0.5 + conv(upsampled, p);
        
for j=1:length(RSB)       
paquet=0;
nb_erreur_global=0; % Cumul de toutes les erreurs 

    while(nb_erreur_global<100) % Tant qu'il n'y a pas eu 100 erreurs cumulées
        
        % Génération du bruit
        sigma2=sigmas2(j);
        nl = randn(length(sl),1)*sqrt(sigma2); % BBGC au rythme Te

        % Ajout du bruit
        yl=nl+sl;
        
        % rl
        rl=conv(yl, fliplr(p))*Te; 

        % Echantillonnage par Ts pour obtenir rm
        rm=rl(length(p):Fse:length(bk)*Fse); % décalage de l'origine due au filtre de mise en forme qui est non causal

        % Decision
        bk_final = rm<0;

        nb_erreur_global=nb_erreur_global+sum(bk_final~=bk);
        paquet=paquet+1;
    end
    
    TEB=[TEB nb_erreur_global/(Nb*paquet)];
end


%% Résultats
figure;
semilogy(RSB_db,TEB);
hold on 
semilogy(RSB_db,erfc(sqrt(RSB))/2); 
hold off
title('Taux d erreur binaire')
xlabel('RSB[dB]');
ylabel('TEB');
legend('TEB theorique','TEB experimentale');
