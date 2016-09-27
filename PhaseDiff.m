function PhaseDiff

d = date;
filename = sprintf('Experimental Data/%s/Ideal1', d);

datain1 = load(filename);
datain1 = datain1.dataout;

fcount = size(datain1);
figure
for x = 1:fcount(1)
    pos = x;
    freq(x,1) = datain1{x,1};
    time = datain1{x,2};
    volts = datain1{x,3};
    v = volts(:,1:2);
    plot(time,v)
    
    w = 347/freq(x);
    percent = .0254/w;
    rad = percent*2*pi;
    
    v = fft(v);
    
    N1 = size(v);
    N1 = N1(1);
    m(x,:) = max(v(2:floor(N1/2)+1,:));
    
    pDummy=m;
%     threshold = min(max(abs(pressures))/10000);
%     pressures(abs(pDummy)<threshold) = 0;

    m(x,2) = abs(m(x,2))*exp(1i*(angle(m(x,2))-rad));
end

x1 = 0;
x2 = x1+.0254;
x3 = x2+.2667;
x4 = x3+.0254;
e = x4 + .3048;

amp1 = abs(m(:,1));
a1 = mean(amp1);
na1 = amp1/a1;
phase1 = unwrap(angle(m(:,1)));
amp2 = abs(m(:,2));
a2 = mean(amp2);
na2 = amp2/a2;
phase2 = unwrap(angle(m(:,2)));

figure
plot(freq,amp1,freq,amp2,freq,a1*ones(size(freq)),freq,a2*ones(size(freq)))
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

figure
plot(freq,na1,freq,na2)
legend('Mic1','Mic2');
title('Normalized Amp')

% a = (amp1./amp2)'
% p = (phase1-phase2)'

end