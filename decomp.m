function [dataout] = decomp(data, mic_status, filename, sheet, freq, pos)

N=length(data);
P1 = data(1:N/2+1,1)./N;
P2 = data(1:N/2+1,2)./N;

%Hcr = 0.00000000000247155696287839*freq^3 + 0.0000000197687770637841*freq^2 + 0.0000694577347183074*freq + 0.448080362913971;
%Hci = (0.0000000000028573550023484*freq^3 - 0.0000000445158054174767*freq^2 + 0.00029509741083379*freq - 0.00897102817477206)*i;

Hcr = 0.0000000355143891842783*freq^2 + 0.0000356135234022613*freq + 0.469629838624252;
Hci = (-0.000000030286287733823*freq^2 + 0.000274368147450973*freq - 0.00608255720457972)*i;

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

    PrPrC = (1/H12+conj(H12)-conj(H12)/H12*exp(-i*k*s)-exp(i*k*s))/((exp(i*k*s)-exp(-i*k*s))*(exp(-i*k*s)-exp(i*k*s))); %we should recalc by hand to verify
    PiPiC = 1/H12+conj(H12)-conj(H12)/H12*exp(i*k*s)-exp(-i*k*s)/((exp(i*k*s)-exp(-i*k*s))*(exp(-i*k*s)-exp(i*k*s))); 
    % i HAVE FEELING THE SINOSOID LIES IN ONE OF THE TWO LINES ABOVE
    
    HI = exp(-j*k*s); 
    HR = exp(j*k*s);
    d = .55;
    r = (H12-HI)/(HR-H12)*exp(2*j*k*d);
    R = abs(r)^2;
    [PtPtC, T] = deal(0);%why do we have transmission data in mic status 1?
    
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
dataout = [freq, S11, S12, S21, S22, PiPiC, PrPrC, PtPtC, R, T, Hr, Hi]; %do we go back to mainAnalysis here?
end