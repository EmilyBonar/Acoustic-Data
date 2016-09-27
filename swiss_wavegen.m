function swiss_wavegen
d = date;
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));
filename=sprintf('Experimental Data/%s/Ideal4', d); %must change to file that you want to save to
freq = [1000:25:5000];
%freq = 1000;

reflection = 1; %causes waves

x(1) = 0;
% x1 = .165+.29845;
x(2) = x(1)+.0254;
x(3) = x(2)+.2667;
x(4) = x(3)+.0254;
e = x(4) + .3048;
% x5 = 2*e-x4;
% x6 = 2*e-x3;
% x7 = 2*e-x2;
% x8 = 2*e-x1;

Fs=2e5; % Sample rate for output signal
Ts = 1/Fs;%duration to take one sample
NT=100; % number of periods per frequency point
c = 343;
A1 = .5; %amplitude of the incident wave
Ar = A1*0.2; %amplitude of the reflected wave
rshift = 180; %phase shift from reflection (radians)

t=0:Ts:Ts*(fix(Fs/4)-1); % initial waiting time = 0.25 seconds
outputSignalcos=t*0;
outputSignalsin=t*0;
w1 = t*0;
w2 = t*0;
w3 = t*0;
w4 = t*0;
for f = 1:length(freq)
    k=2*pi*freq(f)/c;
    
    tn=0:Ts:(NT/freq(f)-Ts); %time vector. NT/freq(f) is the amount of time that NT=(100) periods takes
    outputSignalcos = [outputSignalcos cos(2*pi*-freq(f)*tn)]; %signal sent into tube
    outputSignalsin = [outputSignalsin sin(2*pi*-freq(f)*tn)];
    t=[t tn+t(end)];
    
    p1 = A1*sin(2*pi*-freq(f)*tn+x(1)*k);
    p2 = A1*sin(2*pi*-freq(f)*tn+x(2)*k);
    p3 = A1*sin(2*pi*-freq(f)*tn+x(3)*k);
    p4 = A1*sin(2*pi*-freq(f)*tn+x(4)*k);
    if reflection == 1
        r1 = Ar*sin(2*pi*-freq(f)*tn+x(1)*k+rshift);
        r2 = Ar*sin(2*pi*-freq(f)*tn+x(2)*k+rshift);
        r3 = Ar*sin(2*pi*-freq(f)*tn+x(3)*k+rshift);
        r4 = Ar*sin(2*pi*-freq(f)*tn+x(4)*k+rshift);
        
        p1 = p1+r1;
        p2 = p2+r2;
        p3 = p3+r3;
        p4 = p4+r4;
    end

    w1 = [w1 p1];
    w2 = [w2 p2];
    w3 = [w3 p3];
    w4 = [w4 p4];
    
%     ph1 = k*x;
%     ph2 = rshift+k*x;
%     A2 = 0;
%     
%     if reflection == 1
%         A2 = Ar;
%     end
%     
%     ph = atan((A1*sin(ph1)-A2*sin(ph2))./(A1*cos(ph1)+A2*cos(ph2)));
%     A = (A1*cos(ph1)+A2*cos(ph2))./cos(ph);
%     
%     p = ones(size(tn'))*A.*cos((2*pi*freq(f)*tn)'*ones(size(ph))+ones(size(tn'))*ph);
% 
%     w1 = [w1 p(:,1)'];
%     w2 = [w2 p(:,2)'];
%     w3 = [w3 p(:,3)'];
%     w4 = [w4 p(:,4)'];
%     plot(t, w1, t,w2, t,w3, t,w4)
end

data = [w1' w2' w3' w4' outputSignalcos' outputSignalsin'];

plot(t,data)

% -- Remove offset --
for n=1:4
    mean(data(:,n));
    data(:,n)=(data(:,n)-mean(data(:,n))); %centers voltage data around zero
end

% -- Set t=0 --
n0=find(data(:,5)>.5,1,'first'); %find first value in column 5 of data >.5 
%perhaps defines the first value of t by looking for a suitable amplitude to be set as the reference point for
%all waves
t(1:n0-1)=[];
t=t-t(1); %deletes first all other points in t besides initial ref point then shifts t0 and all other t's to start at 0
data(1:n0-1,:)=[]; %clears all the voltage data to align with t0

n0b=find(outputSignalcos>.5,1,'first'); %sets the ref signal to start at .5 too
%not sure how this shift compares to the actual signal shift
outputSignalcos(1:n0b-1)=[];

% -- Beginning and end of each frequency step --
Nn=NT./freq*Fs; %number of samples for each frequency
for n=1:length(Nn)
    Nc(n)=sum(Nn(1:n));
end
Nc=[0 Nc];
clear n Nn %sums up all the elements of Nn [1 1+1 1+2+3...] then adds a 0 to the begining

%% -- Calculate amplitudes and phases from time signals --

disp(['calculating amplitudes and phases from time signals...'])
for n=1:length(freq) %like or freq in freqrange forloop
    for m=1:4 %probs each mic

        nta=fix(Nc(n)+.3*(Nc(n+1)-Nc(n)));
        ntb=fix(Nc(n)+.8*(Nc(n+1)-Nc(n)));
        
        X = (data(nta:ntb,m)' * data(nta:ntb,5))/length(nta:ntb);
        Y = (data(nta:ntb,m)' * data(nta:ntb,6))/length(nta:ntb);
        Am(m,n) = 2*sqrt(X^2 + Y^2);
        Ph(m,n) = atan2(Y,X);
    end
%          plot(t, data(:,1),'k'), hold on
%          plot(t(nta:ntb), data(nta:ntb,1),'r')
%          hold off,
%          pause()
end


%% -- Computing tramsmissionn and reflection coeffients --
disp(['computing tramsmissionn and reflection coeffients...'])
c1 = 1;
c2 = 1;
c3 = 1;
c4 = 1;
p12=Am(3,:)/c3.*exp(j*Ph(3,:));
p11=Am(4,:)/c4.*exp(j*Ph(4,:));
p21=Am(1,:)/c1.*exp(j*Ph(1,:));
p22=Am(2,:)/c2.*exp(j*Ph(2,:));

p12=Am(1,:)/c3.*exp(j*Ph(1,:));
p11=Am(2,:)/c4.*exp(j*Ph(2,:));
p21=Am(3,:)/c1.*exp(j*Ph(3,:));
p22=Am(4,:)/c2.*exp(j*Ph(4,:));

% -- Transfer functions --
H121=p12./p11;
H221=p22./p21;
H2111=p21./p11;

% -- Wavenumber --
k=2*pi*freq/c;

% -- Distances --
x12 = 0.0;
x11 = x12+.0254;
x21 = x11+10.5*.0254;
x22 = x21+.0254;

% -- Reflection and transmission coefficients -- 
R1 = (H121.*exp(j*k*x11) - exp(j*k*x12)) ./ (exp(-j*k*x12) - H121.*exp(-j*k*x11));
R2 = (H221.*exp(-j*k*x21) - exp(-j*k*x22)) ./ (exp(j*k*x22) - H221.*exp(j*k*x21));
T12 = H2111 .* (exp(j*k*x11) + R1.*exp(-j*k*x11)) ./ (exp(j*k*x21) + 1./R2.*exp(-j*k*x21));

T = T12.*(1-R1./R2)./(1-(T12./R2).^2);
R = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

disp(['done!'])
figure
hold on
plot(freq, abs(T).^2)
plot(freq, abs(R).^2,'r')
%plot(freq, 1-abs(R).^2-abs(T).^2,'g')
grid on
hold off

end