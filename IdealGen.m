function IdealGen
d = date;
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));
filename=sprintf('Experimental Data/%s/Ideal4', d); %must change to file that you want to save to
freq = [1000:100:3000];
%freq = 1000;

measurement = 0; %causes slight trend up or down w/ freq
noise = 0; %adds a tiny bit of variation
attenuation = 0; %squishes graphs towards mean
phase = 0; %causes noisiness
reflection = 1; %causes waves

x1 = 0;
x2 = x1+.0254;
x3 = x2+.2667;
x4 = x3+.0254;
e = x4 + .3048;
x5 = 2*e-x4;
x6 = 2*e-x3;
x7 = 2*e-x2;
x8 = 2*e-x1;

fs = 1e6/8;
c = 343;
A = 1; %amplitude of the incident wave
Ar = A*0.2; %amplitude of the reflected wave
snr = 25; %signal to noise ratio
moffset = .0005; %measurement error range (meters)
poffset = pi/16; %phase error range (radians)
rshift = pi; %phase shift from reflection (radians)

if measurement == 1
    a = 0-moffset;
    b = 0+moffset;
    r = (b-a).*rand(1,3) + a;
    
    x2 = x2+r(1);
    x3 = x3+r(2);
    x4 = x4+r(3);
end

atten = ones(1,8);
ph = zeros(1,4);

t = (0:1/fs:1-1/fs)';

for f = 1:length(freq)
    freq(f)
    k = 2*pi*freq(f)/c;
%     tn=0:Ts:(NT/f(nf)-Ts); %time vector. NT/f(nf) is the amount of time that NF (100) periods takes
%     outputSignalcos = [outputSignalcos cos(2*pi*f(nf)*tn)]; %signals sent into tube
    
    if phase == 1
        a = 0-poffset;
        b = 0+poffset;
        ph = (b-a).*rand(4,1) + a;
    end
    
    p1 = A*sin(2*pi*-freq(f)*t+x1*k+ph(1));
    p2 = A*sin(2*pi*-freq(f)*t+x2*k+ph(2));
    p3 = A*sin(2*pi*-freq(f)*t+x3*k+ph(3));
    p4 = A*sin(2*pi*-freq(f)*t+x4*k+ph(4));
    if noise == 1
        p1 = awgn(p1,snr);
        p2 = awgn(p2,snr);
        p3 = awgn(p3,snr);
        p4 = awgn(p4,snr);
    end
    if attenuation == 1
        atten = -25/576*[x1 x2 x3 x4 x5 x6 x7 x8]+1;
        p1 = p1*atten(1);
        p2 = p2*atten(2);
        p3 = p3*atten(3);
        p4 = p4*atten(4);
    end
    if reflection == 1
        r1 = atten(5)*Ar*sin(2*pi*freq(f)*t+x8*k+ph(1)+rshift);
        r2 = atten(6)*Ar*sin(2*pi*freq(f)*t+x7*k+ph(2)+rshift);
        r3 = atten(7)*Ar*sin(2*pi*freq(f)*t+x6*k+ph(3)+rshift);
        r4 = atten(8)*Ar*sin(2*pi*freq(f)*t+x5*k+ph(4)+rshift);
        
        r1 = atten(5)*Ar*sin(2*pi*freq(f)*t+x1*k+ph(1));
        r2 = atten(6)*Ar*sin(2*pi*freq(f)*t+x2*k+ph(2));
        r3 = atten(7)*Ar*sin(2*pi*freq(f)*t+x3*k+ph(3));
        r4 = atten(8)*Ar*sin(2*pi*freq(f)*t+x4*k+ph(4));
        p1 = p1 + r1;
        p2 = p2 + r2;
        p3 = p3 + r3;
        p4 = p4 + r4;
        
%         figure
%         plot(t, [p1 p2 p3 p4])
%         legend('1','2','3','4')
    end
    
    v = [p1 p2 p3 p4];
    plot(t(1:300),v(1:300,:))
    dataout(f,:) = {freq(f),t,v};
end

disp('Saving Data')
save(filename,'dataout')

end