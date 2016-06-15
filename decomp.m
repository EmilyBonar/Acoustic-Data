function [dataout, HI, HR] = decomp(data, mic_status, filename, sheet, freq, pos)

N=length(data);
P1 = data(1:floor(N/2)+1,1)./N;
P2 = data(1:floor(N/2)+1,2)./N;

Hc = load('Hc');
Hc = ppval(Hc.s,freq); %calculated from experimental testing in an empty channel and interpolated to get the value for the frequency we need

disp('Decomposing Data')
if mic_status == 1
    k = 2*pi*freq/347; %real wavenumber
    x1 = 0.0762;
    x2 = 0.0508;
    s = x1-x2; %distance between mics in m
    
    [a1, m1] = max(P1);
    [a2, m2] = max(P2);
    P1 = P1(m1);
    P2 = P2(m2);
    
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
    
    R = PrPrC/PiPiC;
    [PtPtC, T] = deal(0);
    
    Hr = real(H12); 
    Hi = imag(H12);
    
    S12r = real(P2*conj(P1));
    S12i = imag(P2*conj(P1));
    
elseif mic_status == 2
    data = load('Transmission Data');
    H12 = data.H12(pos);
    HI = data.HI(pos);
    HR = data.HR(pos);
    
    P_T = P1;

    k = 2*pi*freq/347;
    s = 0.0254; %distance between mics in m
    
    [~, m3] = max(abs(P_T));
    P_T = P_T(m3);
    PtPtC = P_T*conj(P_T);
    T = PtPtC/((1/H12+conj(H12)-conj(H12)/H12*HR-HI)/(((HR-HI)*conj(HR-HI))/S12));

    [PiPiC,PrPrC,R, Hr, Hi, S11, S22, S12r, S12i] = deal(0);
end
dataout = [freq, S11, S12r, S12i, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi];
%Remember, S12 = S21*
end