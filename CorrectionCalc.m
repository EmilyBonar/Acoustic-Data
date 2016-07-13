function CorrectionCalc

d = date;
filename1 = sprintf('Experimental Data/%s/M0P0R1-1R', d);
filename2 = sprintf('Experimental Data/%s/M0P0R1-2R', d);

datain1 = load(filename1);
datain1 = datain1.dataout;

datain2 = load(filename2);
datain2 = datain2.dataout;

fcount = size(datain1);
for x = 1:fcount(1)

    pos = x;
    freq(x) = datain1{x,1};
    time = datain1{x,2};
    volts1 = datain1{x,3};
    v1(:,x) = volts1(:,1);
    
    volts2 = datain2{x,3};
    v2(:,x) = volts2(:,1);
end

v1 = fft(v1);
v2 = fft(v2);

N = size(v1);
N = N(1);

v1 = max(v1(2:floor(N/2)+1,:));
v2 = max(v2(2:floor(N/2)+1,:));

amp1 = abs(v1);
phase1 = unwrap(angle(v1));
amp2 = abs(v2);
phase2 = unwrap(angle(v2));

figure
plot(freq,amp1,freq,amp2)
legend('Mic1','Mic2');
title('Amp')

figure
plot(freq,phase1,freq,phase2)
legend('Mic1','Mic2');
title('Phase')

figure
plot(freq, amp1./amp2)
title('Amp Correction')

figure
e = polyfit(freq, phase1-phase2, 1);
plot(freq, phase1-phase2, freq, polyval(e,freq))
legend('Raw','Trend');
title('Phase Correction')

% a = (amp1./amp2)'
% p = (phase1-phase2)'

end