function [registre] = bit2registre(registre, data)

crc_poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
detecteur = crc.detector(crc_poly);
[decoded error] = detect(detecteur, data);

if error==0 % Si pas d'erreur dans le CRC
    %%> FORMAT
    registre.format = bi2de(data(1:5)', 'left-msb');
    %%> ADRESSE
    registre.adresse = dec2hex(bin2dec(int2str(data(9:32)')));
    %%> TYPE
    registre.type = bi2de(data(33:37)', 'left-msb');
    
    if(registre.format == 17) % on ne considère que ce type de messages ADS-B
        if ((registre.type >= 1) && (registre.type <= 4)) % Identification
            %%> NOM
            nom = [bi2de(data(41:46)','left-msb') bi2de(data(47:52)','left-msb') ...
                    bi2de(data(53:58)','left-msb') bi2de(data(59:64)','left-msb') ...
                    bi2de(data(65:70)','left-msb') bi2de(data(71:76)','left-msb') ...
                    bi2de(data(77:82)','left-msb') bi2de(data(83:88)','left-msb')];
            lettres = nom<27;
            nom(lettres) = nom(lettres)+64; % décalage par rapport à la table ASCII pour les lettres
            registre.nom = char(nom);
        elseif ((registre.type >= 9) && (registre.type <= 18)) % Localisation
            %%> TIME FLAG UTC
            registre.timeFlag = data(53);
            %%> CPR FLAG
            i = data(54);
            registre.cprFlag = data(54);
            %%> ALTITUDE
            registre.altitude = 25 * bi2de([data(41:47)' data(49:52)'], 'left-msb') - 1000;
            %%> LATITUDE
            lat_ref = 44.806884;
            LAT = bi2de(data(55:71)', 'left-msb');
            Dlat = 360 / (4*15 - registre.cprFlag); % 15=Nz
            j = floor(lat_ref/Dlat) + floor(1/2 ... 
                + (lat_ref-Dlat*floor(lat_ref/Dlat))/Dlat ...
                - LAT/(2^17));
            registre.latitude = Dlat*(j+ LAT/2^17);
            %%> LONGITUTDE
            long_ref = -0.606629;
            LON = bi2de(data(72:88)', 'left-msb');
            if((cprNL(registre.latitude) - registre.cprFlag)>0) % calcul de Dlon
                Dlon = 360/(cprNL(registre.latitude) - registre.cprFlag);
            else
                Dlon = 360;
            end
            m = floor(long_ref/Dlon) ...
                + floor(1/2 + (long_ref - Dlon*floor(long_ref/Dlon))/Dlon ...
                - (LON/2^17) );
            registre.longitude = Dlon*(m + LON/2^17);
            %%> TRAJECTOIRE
            registre.trajectoire = [registre.trajectoire  ... 
                [registre.longitude ; registre.latitude ; registre.altitude]];
        end    
    end % END if(type == 17)
end % END if pas d'erreur dans le CRC

end

