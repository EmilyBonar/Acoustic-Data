function [dataout, PiPiC] = decomp(data, freq)

N=length(data);
P1 = data(1:floor(N/2)+1,1)./N;
P2 = data(1:floor(N/2)+1,2)./N;
P3 = data(1:floor(N/2)+1,3)./N;

Hc = load('Hc');
Hc = ppval(Hc.s,freq); %calculated from experimental testing in an empty channel and interpolated to get the value for the frequency we need

disp('Decomposing Data')

k = 2*pi*freq/347; %real wavenumber
x1 = 0.0762;
x2 = 0.0508;
s = x1-x2; %distance between mics in m

P_T = P3;

P1 = max(P1);
P2 = max(P2);
P_T = max(P_T);

S11 = P1*conj(P1);
S12 = P2*conj(P1);
S21 = P1*conj(P2);
S22 = P2*conj(P2);

H12 = S12/S11;
H12 = H12/Hc;

HI = exp(-i*k*s);
HR = exp(i*k*s);

PrPrC = (1/H12+conj(H12)-conj(H12)/H12*HI-HR)/(((HR-HI)*conj(HR-HI))/S12);
PiPiC = (1/H12+conj(H12)-conj(H12)/H12*HR-HI)/(((HR-HI)*conj(HR-HI))/S12);
PtPtC = P_T*conj(P_T);

R = PrPrC/PiPiC;
T = PtPtC/PiPiC;

Hr = real(H12); 
Hi = imag(H12);

S12r = real(P2*conj(P1));
S12i = imag(P2*conj(P1));

dataout = [freq, S11, S12r, S12i, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi];
%Remember, S12 = S21*
end