function [dataout] = decomp(data, mic_status, filename, sheet, freq, pos)

N=length(data);
P1 = data(1:N/2+1,1)./N;
P2 = data(1:N/2+1,2)./N;

coeff = load('Hc');
Hcr = polyval(coeff.rline, freq);
Hci = polyval(coeff.iline, freq)*i;

Hc = Hcr+Hci; %calculated from experimental testing in an empty channel

if mic_status == 1
    k = 2*pi*freq/347; %real wavenumber
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
    
    HI = exp(-i*k*s); 
    HR = exp(i*k*s);

    PrPrC = (1/H12+conj(H12)-conj(H12)/H12*HI-HR)/((HR-HI)*(HI-HR));
    PiPiC = (1/H12+conj(H12)-conj(H12)/H12*HR-HI)/((HR-HI)*(HI-HR));
    
    R = PrPrC/PiPiC;
    [PtPtC, T] = deal(0);
    
    Hr = real(H12); 
    Hi = imag(H12);
    
    save('Transmission Data', 'S11', 'S12', 'S21','S22')
    
elseif mic_status == 2
    load('Transmission Data')
    
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