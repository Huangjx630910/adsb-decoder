function [ delta_t_est ] = synchronisation (rl, sp, mat_delta_t, Tp, Te, Fse)
% Calcule et renvoie l'estimation du délai de propagation delta_t
    
    TpF=Tp*Fse;
    
    % Numerateur 
    r1=xcorr(rl,sp);
    a1=r1(floor(length(r1)/2)+1:length(r1));
     
    % Denominateur 1 
    a2=0;
    for i=0+1:TpF
        a2=a2+abs(sp(1,i)).^2;
    end
    a2=sqrt(a2);
        
         
    % Dénominateur 2 
    u=[ones(1,TpF) zeros(1,length(rl)-TpF)]; 
    r2=xcorr(rl.^2,u);
    a3=r2(floor(length(r2)/2)+1:length(r2));
    a3=sqrt(a3);
    

    % p
    p=[a1./(a2*a3)];
     
    
    % Argmax de p
    [max_p, argmax_p] = max(p);
    
    delta_t_est=argmax_p-1; % Soustraction de 1 car t0=t1 sous Matlab
    
    plot(p)
    title('Evolution de p en focntion de delta t');
end

