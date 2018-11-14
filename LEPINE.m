function listeRegistresOut =LEPINE(listeRegistresIn,cplxBuffer,Fe,Ds,REF_LON,REF_LAT)
% Veuillez garder ce nom de fonction et cet ordre dans les paramètres

Fse = Fe/Ds;
p=[-0.5*ones(1,Fse/2) 0.5*ones(1,Fse/2)]; % filtre

%% Synchronisation buffer complexe
%TODO

%% Récupération trames avec seuillage (0.7)
%TODO
trames = cplxBuffer; % dont chaque colonne est une trame ADSB non décodée

%% Décodage trames vers binaire
[~,m] = size(trames);
p=[-0.5*ones(1,Fse/2) 0.5*ones(1,Fse/2)];
adsb_msgs = [];
for i = 1:m
    % Filtre adapté - Convolution pour obtenir rl(t)
    yl = abs(trames(:,i));
    rl=conv(yl, fliplr(p));
    % Echantillonnage par Ts pour obtenir rm
    indices = Fse:Fse:length(rl);
    rm=rl(indices);
    % Décision
    decoded_est = rm<0;
    adsb_msgs = [adsb_msgs [decoded_est(9:end)]];
end

%% Traitement des trames binaires
[~,nb_adsb_msgs] = size(adsb_msgs);
nb_avions = numel(ListRegIn);
for i=1:nb_adsb_msgs
   temp_registre = struct('adresse', [], ...
                  'format', [], ...
                  'type', [], ...
                  'nom', [], ...
                  'altitude', [], ...
                  'timeFlag', [], ...
                  'cprFlag', [], ...
                  'latitude', [], ...
                  'longitude', [], ...
                  'trajectoire', []);
    temp_registre = bit2registre(temp_registre, adsb_msgs(:,i), REF_LON, REF_LAT);
    trouve = false;
    for j=1:nb_avions
        if strcmp(listeRegistresIn(i).adresse, temp_registre.adresse) % on a reconnu un avion existant
            if(~isempty(temp_registre.nom))
               listeRegistresIn(i).nom = temp_registre.nom; 
            end
            if(temp_registre.latitude ~= 0)
                listeRegistresIn(i).latitude = temp_registre.latitude;
                listeRegistresIn(i).longitude = temp_registre.longitude;
                listeRegistresIn(i).altitude = temp_registre.altitude;
                listeRegistresIn(i).trajectoire = [listeRegistresIn(i).trajectoire ... 
                    [temp_registre.longitude ; temp_registre.latitude; temp_registre.altitude]];
            end
            trouve = true;            
        end
    end
    
    if ~trouve
        new_registre = struct('adresse', [], ...
                  'nom', [], ...
                  'altitude', [], ...
                  'latitude', [], ...
                  'longitude', [], ...
                  'trajectoire', []);
        if(~isempty(temp_registre.nom))
           new_registre.nom = temp_registre.nom; 
        end
        if(temp_registre.latitude ~= 0)
            new_registre.latitude = temp_registre.latitude;
            new_registre.longitude = temp_registre.longitude;
            new_registre.altitude = temp_registre.altitude;
            new_registre.trajectoire = [[temp_registre.longitude ; temp_registre.latitude; temp_registre.altitude]];
        end
       listeRegistresIn = [listeRegistresIn new_registre];
    end
end

%% Renvoi des nouveaux registres
listeRegistresOut = listeRegistresIn;