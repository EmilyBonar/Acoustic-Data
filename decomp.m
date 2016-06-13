function [dataout, HI, HR] = decomp(data, mic_status)

N=length(data);
P1 = data(1:floor(N/2)+1,1)./N;
P2 = data(1:floor(N/2)+1,2)./N;
P1 = P1(2:25001);
P2 = P2(2:25001);

freq = .2*[1:length(P1)]';
% 
% coeff = load('Hc');
% Hcr = polyval(coeff.rline, freq);
% Hci = polyval(coeff.iline, freq)*i;
% 
% Hc = Hcr+Hci; %calculated from experimental testing in an empty channel

if mic_status == 1
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
    
    R = PrPrC./PiPiC;
    [PtPtC, T] = deal(zeros(length(H12),1));
    
    Hr = real(H12);
    Hi = imag(H12);
    
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
    T = PtPtC/((1/H12+conj(H12)-conj(H12)/H12*HR-HI)/((HR-HI)*conj((HR-HI))));

    [PiPiC,PrPrC,R, Hr, Hi, S11, S22, S12, S21] = deal(0);
end
dataout = [freq, S11, S12, S21, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi];

end