function [dataout] = decomp(data, mic_status, filename, sheet, freq, f)

N=length(data);
P1 = data(1:N/2+1,1)./N;
P2 = data(1:N/2+1,2)./N;

pos = find(f == freq);

% Hcr = -0.000000000000825368948204012*freq^3 + 0.0000000367600680699613*freq^2 + 0.000030183126278669*freq + 0.514090471563409;
% Hci = (-0.00000000000608027861484434*freq^3 + 0.00000000271334807728935*freq^2 + 0.000215280179365063*freq + 0.0173487044961814)*i;
Hcr = 0.00000000000247155696287839*freq^3 + 0.0000000197687770637841*freq^2 + 0.0000694577347183074*freq + 0.448080362913971;
Hci = (0.0000000000028573550023484*freq^3 - 0.0000000445158054174767*freq^2 + 0.00029509741083379*freq - 0.00897102817477206)*i;

Hc = Hcr+Hci;

if mic_status == 1
    k = 2*pi*freq/347;
    x1 = 0.0762;
    x2 = 0.0508;
    s = x1-x2; %distance between mics in m
    
    [~, m1] = max(abs(P1));
    [~, m2] = max(abs(P2));
    P1 = P1(m1);
    P2 = P2(m2);
    
    S11 = P1*conj(P1);
    S12 = P2*conj(P1);
    S21 = P1*conj(P2);
    S22 = P2*conj(P2);
    
    H12 = S12/S11;
    H12 = H12/Hc;

    PrPrC = (1/H12+conj(H12)-conj(H12)/H12*exp(-i*k*s)-exp(i*k*s))/((exp(i*k*s)-exp(-i*k*s))*(exp(-i*k*s)-exp(i*k*s)));
    PiPiC = 1/H12+conj(H12)-conj(H12)/H12*exp(i*k*s)-exp(-i*k*s)/((exp(i*k*s)-exp(-i*k*s))*(exp(-i*k*s)-exp(i*k*s)));
    
    HI = exp(-j*k*s);
    HR = exp(j*k*s);
    d = .55;
    r = (H12-HI)/(HR-H12)*exp(2*j*k*d);
    R = abs(r)^2;
    [PtPtC, T] = deal(0);
    
    Hr = real(H12);
    Hi = imag(H12);
    
elseif mic_status == 2
    S11 = xlsread(filename,sheet,sprintf('B%i',pos+1));
    S12 = xlsread(filename,sheet,sprintf('C%i',pos+1));
    S21 = xlsread(filename,sheet,sprintf('D%i',pos+1));
    S22 = xlsread(filename,sheet,sprintf('E%i',pos+1));
    
    P_T = P1;

    k = 2*pi*freq/347;
    s = 0.0254; %distance between mics in m
    
    [~, m3] = max(abs(P_T));
    P_T = P_T(m3);
    PtPtC = P_T*conj(P_T);
    T = PtPtC/(S11+S22-S21*exp(i*k*s)-S12*exp(-i*k*s));

    [PiPiC,PrPrC,R, Hr, Hi] = deal(0);
end
dataout = [freq, S11, S12, S21, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi];
end