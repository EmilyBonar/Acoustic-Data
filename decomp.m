function [dataout, PiPiC] = decomp(data, freq, correct)

N=length(data);
P1 = data(1:floor(N/2)+1,1)./N;
P2 = data(1:floor(N/2)+1,2)./N;
P3 = data(1:floor(N/2)+1,3)./N;
P4 = data(1:floor(N/2)+1,4)./N;

disp('Decomposing Data')

k = 2*pi*freq/347; %real wavenumber
%x12 = .165+.29845;
x12 = 0;
x11 = x12+.0254;
x21 = x11+.2667;
x22 = x21+.0254;

P1 = max(P1);
P2 = max(P2);
P3 = max(P3);
P4 = max(P4);

if correct == 1
    c = load('Correction Data');
    a2 = abs(P2);
    p2 = angle(P2);
    a4 = abs(P4);
    p4 = angle(P4);
    
    a2 = a2*polyval(c.amp,freq);
    p2 = p2+polyval(c.phase,freq);
    a4 = a4*polyval(c.amp,freq);
    p4 = p4+polyval(c.phase,freq);
    
    P2 = a2*exp(i*p2);
    P4 = a4*exp(i*p4);
end

H21_1 = P1/P2;
H21_2 = P4/P3;
H11_21 = P3/P2;

R1 = (H121.*exp(j*k*x11) - exp(j*k*x12)) ./ (exp(-j*k*x12) - H121.*exp(-j*k*x11));
R2 = (H221.*exp(-j*k*x21) - exp(-j*k*x22)) ./ (exp(j*k*x22) - H221.*exp(j*k*x21));
T12 = H2111 .* (exp(j*k*x11) + R1.*exp(-j*k*x11)) ./ (exp(j*k*x21) + 1./R2.*exp(-j*k*x21));

T = T12.*(1-R1./R2)./(1-(T12./R2).^2);
R = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

dataout = [freq, real(H21_1),imag(H21_1),real(H21_2),imag(H21_2), real(H11_21),imag(H11_21), R, T];
end