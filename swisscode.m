% This script measures the transmission and reflection coefficient using 
% the two-port technique. 
%
% Miguel Moleron, ETH, Jun 2016
% 

clearvars
% %close all
clc

d = date;
filename=sprintf('Experimental Data/%s/M0P0R1-1R', d); %must change to file that you want to load from
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));

%filename='Mic 3 Position 1'; %must change to file that you want to load from
%% -- Microphone calibration --
c1=0.00425;     %V/Pa
c2=0.00386;
c3=0.00402;
c4=0.00397;

m1 = 6.5534;    %Pa
m2 = 6.6631;
m3 = 5.6280;
m4 = 5.6200;

% -- Distances --
x1 = 0.0;
x2 = x1+.0254;
x3 = x2+19.25*.0254;
x4 = x3+.0254;

%% -- Initialiyze DAQ --
s = daq.createSession('ni');
Fs=1e5; % Sample rate for output signal
s.Rate = Fs; % Sample rate for input signals
Ts=1/Fs; %time between samples, (100k)^-1 sec/sample
f=[1500:10:2500]; % frequencies to evaluate
delay = 2; %number of frequencies to chop off the front
NT=200; % number of periods per frequency point
A=.3; %amplitude in V
c=344;

%% -- Adding output and input channels --

%warning off

% -- Outputs -- 
addAnalogOutputChannel(s,'cDAQ1Mod1',0,'Voltage'); % cos ouput Blue housing module is output waves
addAnalogOutputChannel(s,'cDAQ1Mod1',1,'Voltage'); % sin output

% -- Inputs -- 
ch1 = addAnalogInputChannel(s,'cDAQ1Mod2',0,'Voltage'); % mic 1 Black housing module is input waves
ch2 = addAnalogInputChannel(s,'cDAQ1Mod2',1,'Voltage'); % mic 2
ch3 = addAnalogInputChannel(s,'cDAQ1Mod2',2,'Voltage'); % mic 3
ch4 = addAnalogInputChannel(s,'cDAQ1Mod2',3,'Voltage'); % mic 4
ch5 = addAnalogInputChannel(s,'cDAQ1Mod2',4,'Voltage'); % cos input
ch6 = addAnalogInputChannel(s,'cDAQ1Mod2',5,'Voltage'); % sin input
% ch1.Range = [-5,5];
% ch2.Range = [-5,5];
% ch3.Range = [-5,5];
% ch4.Range = [-5,5];
% ch5.Range = [-5,5];
% ch6.Range = [-5,5];

%warning on

disp(['generating output singal...'])
t=0:Ts:Ts*(fix(Fs/4)-1); % this is the time vector initial waiting time = 0.25 seconds 
f = [f(1)-(f(2)-f(1))*delay:(f(2)-f(1)):f(1)-(f(2)-f(1)) f];
outputSignalcos=t*0;
outputSignalsin=t*0;
for nf=1:length(f) %like for loop going through each freq in freqrange
    tn=0:Ts:(NT/f(nf)); %time vector. NT/f(nf) is the amount of time that NF (200) periods takes
    outputSignalcos = [outputSignalcos A*cos(2*pi*f(nf)*tn)]; %signals sent into tube
    outputSignalsin = [outputSignalsin A*sin(2*pi*f(nf)*tn)];
    t=[t tn+t(end)];
end

%% -- Perform Frequency sweep -- 
disp(['performing frequency sweep...'])
queueOutputData(s,[outputSignalcos' outputSignalsin']);
data=s.startForeground; %starts collecting data

% -- Remove offset --
for n=1:4
    data(:,n)=(data(:,n)-mean(data(:,n))); %centers voltage data around zero
end

% -- Set t=0 --
n0=find(data(:,5)>.1,1,'first'); %find first value in column 5 of data >.1
%perhaps defines the first value of t by looking for a suitable amplitude to be set as the reference point for
%all waves
t(1:n0-1)=[];
t=t-t(1); %deletes first all other points in t besides initial ref point then shifts t0 and all other t's to start at 0
data(1:n0-1,:)=[]; %clears all the voltage data to align with t0

n0b=find(outputSignalcos>.1,1,'first'); %sets the ref signal to start at .1 too
outputSignalcos(1:n0b-1)=[]; %seems to be unused

%  figure()
%  plot(data(:,1:4)) %blue is mic 1

% -- Beginning and end of each frequency step --
Nn=NT./f*Fs; %number of samples for each frequency
if delay ~= 0
    s = 0;
    for x = 1:delay
        s = s + Nn(x);
    end
    data = data(floor(s-1):end,:);
    f = f(delay+1:end);
    Nn=NT./f*Fs; %number of samples for each frequency
end

for n=1:length(Nn)
    Nc(n)=sum(Nn(1:n));
end
Nc=[0 Nc];% number of samples before given frequency
clear n Nn %sums up all the elements of Nn [1 1+1 1+2+3...] then adds a 0 to the begining

%% -- Calculate amplitudes and phases from time signals --

disp(['calculating amplitudes and phases from time signals...'])
for n=1:length(f) %like or freq in freqrange forloop
    
%     figure
%     hold on
    
    nta=fix(Nc(n)+.3*(Nc(n+1)-Nc(n)));%nta starting point (sample) for frequency f
    ntb=fix(Nc(n)+.8*(Nc(n+1)-Nc(n))); %end point for frequency f
    for m=1:4 %probs each mic

%         plot(data(nta:ntb,m))
       
        X = (data(nta:ntb,m)' * data(nta:ntb,5))/length(nta:ntb);
        Y = (data(nta:ntb,m)' * data(nta:ntb,6))/length(nta:ntb);
        Am(n,m) = 2*sqrt(X^2 + Y^2);
        Ph(n,m) = atan2(Y,X);
    end
%     plot(data(nta:ntb,5))
%     plot(data(nta:ntb,6))
    uPh = unwrap(Ph);

%     hold off
end

ft= fft(data(:,1));
% plot(ft,size(data,1))

for n=1:length(f);
    mPh(n,1)=2*pi*x1*f(n)/c; %used only as 0 ref
    mPh(n,2)=2*pi*x2*f(n)/c; %phase in rad off the signal should be from ref
    mPh(n,3)=2*pi*x3*f(n)/c;
    mPh(n,4)=2*pi*x4*f(n)/c;
    
    phaseoff(n,1) = (uPh(n,1) - uPh(n,1)) - (mPh(n,1) - mPh(n,1));
    phaseoff(n,2) = (uPh(n,2) - uPh(n,1)) - (mPh(n,2) - mPh(n,1));
    phaseoff(n,3) = (uPh(n,3) - uPh(n,1)) - (mPh(n,3) - mPh(n,1));
    phaseoff(n,4) = (uPh(n,4) - uPh(n,1)) - (mPh(n,4) - mPh(n,1));
end

%phaseoff=unwrap(Ph)-mph %how much each mic is off at each freq in radians
figure
plot(f,uPh);
legend('1','2','3','4')

figure
plot(f,Am);
legend('1','2','3','4')

%% -- Computing tramsmissionn and reflection coeffients --
% disp(['computing tramsmissionn and reflection coeffients...'])

p1=Am(:,1)/c1.*exp(1i*Ph(:,1));
p2=Am(:,2)/c2.*exp(1i*Ph(:,2));
p3=Am(:,3)/c3.*exp(1i*Ph(:,3));
p4=Am(:,4)/c4.*exp(1i*Ph(:,4));

% -- Transfer functions --
H21=p1./p2;
H34=p4./p3;
H23=p3./p2;

% -- Wavenumber --
k=2*pi*f'/c;

% -- Reflection and transmission coefficients -- 
R1 = (H21.*exp(1i*k*x2) - exp(1i*k*x1)) ./ (exp(-1i*k*x1) - H21.*exp(-1i*k*x2));
R2 = (H34.*exp(-1i*k*x3) - exp(-1i*k*x4)) ./ (exp(1i*k*x4) - H34.*exp(1i*k*x3));
T12 = H23 .* (exp(1i*k*x2) + R1.*exp(-1i*k*x2)) ./ (exp(1i*k*x3) + 1./R2.*exp(-1i*k*x3));

T = T12.*(1-R1./R2)./(1-(T12./R2).^2);
R = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

disp(['done!'])
figure
hold on
plot(f, abs(T).^2)                  %transmission
plot(f, abs(R).^2,'r')              %reflection
plot(f, abs(R).^2+abs(T).^2,'g')    %absorbtion
grid on
ylim([-.1 1.2])
legend('T','R','R+T')

save(filename, 'Ph','Am')

%clearvars