function [dataout, PiPiC] = decomp(data, freq, pos, mic_status, HcOn)

N=length(data);
P1 = data(1:floor(N/2)+1,1)./N;
P2 = data(1:floor(N/2)+1,2)./N;
P3 = data(1:floor(N/2)+1,3)./N;

disp('Decomposing Data')

k = 2*pi*freq/347; %real wavenumber
x1 = 0.0762;
x2 = 0.0508;
s = x1-x2; %distance between mics in m

P1 = max(P1);
P2 = max(P2);

Hc = 1;

if mic_status == 1
    if HcOn == 1
        Hc = load('HcR');
        Hc = ppval(Hc.r,freq); %calculated from experimental testing in an empty channel and interpolated to get the value for the frequency we need
    end
    P_T = P3;
    
    P_T = max(P_T);

    S11_R = P1*conj(P1);
    S12_R = P2*conj(P1);
    S21_R = P1*conj(P2);
    S22_R = P2*conj(P2);

    H12 = S12_R/S11_R;
    H12 = H12/Hc;

    HI = exp(-i*k*s);
    HR = exp(i*k*s);

    PrPrC_R = S11_R*(1+conj(H12)*H12-conj(H12)*HI-H12*HR)/((HR-HI)*conj(HR-HI));
    PiPiC = S11_R*(1+conj(H12)*H12-conj(H12)*HR-H12*HI)/((HR-HI)*conj(HR-HI));
    PtPtC_R = P_T*conj(P_T);
    
    R_R = PrPrC_R/PiPiC;
    T_R = PtPtC_R/PiPiC;

    Hr_R = real(H12); 
    Hi_R = imag(H12);

    S12r_R = real(S12_R);
    S12i_R = imag(S12_R);
    
    [S11_T, S12r_T, S12i_T, S22_T, PrPrC_T, PtPtC_T, R_T, T_T, Hr_T, Hi_T] = deal(0);
elseif mic_status == 2
    if HcOn == 1
        Hc = load('HcT');
        Hc = ppval(Hc.t,freq); %calculated from experimental testing in an empty channel and interpolated to get the value for the frequency we need
    end
    
    data = load('Transmission Data');
    PiPiC = data.PiPiC(pos);
    
    S11_T = P1*conj(P1);
    S12_T = P2*conj(P1);
    S21_T = P1*conj(P2);
    S22_T = P2*conj(P2);

    H12 = S12_T/S11_T;
    H12 = H12/Hc;

    HI = exp(-i*k*s);
    HR = exp(i*k*s);

    PrPrC_T = S11_T*(1+conj(H12)*H12-conj(H12)*HI-H12*HR)/((HR-HI)*conj(HR-HI));
    PtPtC_T = S11_T*(1+conj(H12)*H12-conj(H12)*HR-H12*HI)/((HR-HI)*conj(HR-HI));
    
    R_T = PrPrC_T/PiPiC;
    T_T = PtPtC_T/PiPiC;

    Hr_T = real(H12); 
    Hi_T = imag(H12);

    S12r_T = real(S12_T);
    S12i_T = imag(S12_T);
    
    [S11_R, S12r_R, S12i_R, S22_R, PiPiC, PrPrC_R, PtPtC_R, R_R, T_R, Hr_R, Hi_R] = deal(0);
end

dataout = [freq, S11_R, S12r_R, S12i_R, S22_R, PiPiC, PrPrC_R, PtPtC_R, R_R, T_R, Hr_R, Hi_R, S11_T, S12r_T, S12i_T, S22_T, PrPrC_T, PtPtC_T, R_T, T_T, Hr_T, Hi_T];
%Remember, S12 = S21*
end