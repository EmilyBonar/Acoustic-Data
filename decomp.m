function [dataout, HI, HR] = decomp(data, time, band, mic_status)

N=length(data);
P1 = data(1:floor(N/2)-1,1)./N;
P2 = data(1:floor(N/2)-1,2)./N;
P3 = data(1:floor(N/2)-1,3)./N;
P1 = P1(2:int64(max(max(time))*(max(band)))+1);
P2 = P2(2:int64(max(max(time))*(max(band)))+1);
P3 = P3(2:int64(max(max(time))*(max(band)))+1);

P_T = P3;

freq = double(int64(1/max(max(time))*[1:length(P1)]'));

%plot(freq, abs(P1), freq, abs(P2))
% 
% coeff = load('Hc');
% Hcr = polyval(coeff.rline, freq);
% Hci = polyval(coeff.iline, freq)*i;
% 
% Hc = Hcr+Hci; %calculated from experimental testing in an empty channel

disp('Decomposing Data')

k = 2*pi*freq/347; %real wavenumber
x1 = 0.0762;
x2 = 0.0508;
s = x1-x2; %distance between mics in m

S11 = P1.*conj(P1);
S12 = P2.*conj(P1);
S21 = P1.*conj(P2);
S22 = P2.*conj(P2);

H12 = S12./S11;
%H12 = H12./Hc;

HI = exp(-i*k*s);
HR = exp(i*k*s);

PrPrC = (1./H12+conj(H12)-conj(H12)./H12.*HI-HR)./((HR-HI).*conj((HR-HI)));
PiPiC = (1./H12+conj(H12)-conj(H12)./H12.*HR-HI)./((HR-HI).*conj((HR-HI)));
PtPtC = P_T.*conj(P_T);

R = PrPrC./PiPiC;
T = PtPtC./((1./H12+conj(H12)-conj(H12)./H12.*HR-HI)./((HR-HI).*conj((HR-HI))));

Hr = real(H12);
Hi = imag(H12);

dataout = [freq, S11, S12, S21, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi];

end