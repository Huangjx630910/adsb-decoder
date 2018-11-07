function [y] = Mon_Welch(x, NFFT)
%MON_WELCH Méthoded de Welch pour l'estimation de la DSP pour un découpage
% en 256 points

Nb_FFT = round(length(x)/NFFT);
y = zeros(1, NFFT);

for i=0:Nb_FFT-1
    x_segment = x(i*NFFT+1:(i+1)*NFFT);
    temp = abs(fftshift(fft(x_segment))).^2;
    y(:) = y(:)+temp;
end

y=y/Nb_FFT;
end

