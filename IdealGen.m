function IdealGen
d = date;
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));
filename=sprintf('Experimental Data/%s/Ideal5', d); %must change to file that you want to save to

measurement = 1;
noise = 0;
attenuation = 0;
phase = 0;
reflection = 1;

x1 = 0;
x2 = x1+.0254;
x3 = x2+.2667;
x4 = x3+.0254;
e = x4 + .3048;

samplerate = 1e6/8;
A = 1;
Ar = A*0.2;
snr = 25; %what is this?
moffset = .0005;
poffset = pi/16;

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

freq = [1000:10:3000];
t = (0:1/samplerate:1-1/samplerate)';

for f = 1:length(freq)
    freq(f)
    
    if phase == 1
        a = 0-poffset;
        b = 0+poffset;
        ph = (b-a).*rand(4,1) + a;
    end
    
    p1 = A*sin(2*pi*freq(f)*t+ph(1));
    p2 = A*sin(2*pi*freq(f)*t+x2/347*freq(f)*2*pi+ph(2));
    p3 = A*sin(2*pi*freq(f)*t+x3/347*freq(f)*2*pi+ph(3));
    p4 = A*sin(2*pi*freq(f)*t+x4/347*freq(f)*2*pi+ph(4));
    
    if noise == 1
        p1 = awgn(p1,snr);
        p2 = awgn(p2,snr);
        p3 = awgn(p3,snr);
        p4 = awgn(p4,snr);
    end
    if attenuation == 1
        atten = -25/576*[x1 x2 x3 x4 2*e-x4 2*e-x3 2*e-x2 2*e-x1]+1;
        p1 = p1*atten(1);
        p2 = p2*atten(2);
        p3 = p3*atten(3);
        p4 = p4*atten(4);
    end
    if reflection == 1
        p1 = p1 + atten(5)*Ar*sin(2*pi*freq(f)*t+2*(e-x1)/347*freq(f)*2*pi+ph(1)+pi);
        p2 = p2 + atten(6)*Ar*sin(2*pi*freq(f)*t+2*(e-x2)/347*freq(f)*2*pi+ph(2)+pi);
        p3 = p3 + atten(7)*Ar*sin(2*pi*freq(f)*t+2*(e-x3)/347*freq(f)*2*pi+ph(3)+pi);
        p4 = p4 + atten(8)*Ar*sin(2*pi*freq(f)*t+2*(e-x4)/347*freq(f)*2*pi+ph(4)+pi);
    end
    
    v = [p1 p2 p3 p4];
    dataout(f,:) = {freq(f),t,v};
end

disp('Saving Data')
save(filename,'dataout')

end