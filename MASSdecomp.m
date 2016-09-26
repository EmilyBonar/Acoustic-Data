function [dataout, PiPiC] = MASSdecomp(data, freq, correct)

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

H121 = P1/P2;
H221 = P4/P3;
H2111 = P3/P2;

R1 = (H121.*exp(j*k*x11) - exp(j*k*x12)) ./ (exp(-j*k*x12) - H121.*exp(-j*k*x11));
R2 = (H221.*exp(-j*k*x21) - exp(-j*k*x22)) ./ (exp(j*k*x22) - H221.*exp(j*k*x21));
T12 = H2111 .* (exp(j*k*x11) + R1.*exp(-j*k*x11)) ./ (exp(j*k*x21) + 1./R2.*exp(-j*k*x21));

t = T12.*(1-R1./R2)./(1-(T12./R2).^2);
r = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

T = abs(t).^2;
R = abs(r).^2;

S11 = P1.*conj(P1);
S12 = P2.*conj(P1);
S21 = P1.*conj(P2);
S22 = P2.*conj(P2);

H12 = S12./S11;
H12 = H12./Hc;

HI = exp(-i*k*s);
HR = exp(i*k*s);

PrPrC = (1./H12+conj(H12)-conj(H12)./H12.*HI-HR)./(((HR-HI).*conj((HR-HI)))./S12);
PiPiC = (1./H12+conj(H12)-conj(H12)./H12.*HR-HI)./(((HR-HI).*conj((HR-HI)))./S12);
PtPtC = P3.*conj(P3);

R = PrPrC./PiPiC;
T = PtPtC./PiPiC;

dataout = [freq, real(H121),imag(H121),real(H221),imag(H221), real(H2111),imag(H2111), R, T];
end