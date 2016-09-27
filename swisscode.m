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
c1=0.00425;
c2=0.00386;
c3=0.00402;
c4=0.00397;

m1 = 6.5534;
m2 = 6.6631;
m3 = 5.6280;
m4 = 5.6200;

% -- Distances --
x1 = 0.0;
x2 = x1+.0254;
x3 = x2+10.5*.0254;
x4 = x3+.0254;

%% -- Initialiyze DAQ --
s = daq.createSession('ni');
Fs=1e5; % Sample rate for output signal
s.Rate = Fs; % Sample rate for input signals
Ts=1/Fs; %time between samples, (100k)^-1 sec/sample
f=[1500:2:2500]; % frequencies to evaluate
delay = 2; %number of frequencies to chop off the front
NT=200; % number of periods per frequency point
A=.5; %amplitude in V

%% -- Adding output and input channels --

warning off

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
ch1.Range = [-5,5];
ch2.Range = [-5,5];
ch3.Range = [-5,5];
ch4.Range = [-5,5];
ch5.Range = [-5,5];
ch6.Range = [-5,5];

warning on

disp(['generating output singal...'])
t=0:Ts:Ts*(fix(Fs/4)-1); % this is the time vector initial waiting time = 0.25 seconds 
f = [f(1)-(f(2)-f(1))*delay:(f(2)-f(1)):f(1)-(f(2)-f(1)) f];
outputSignalcos=t*0;
outputSignalsin=t*0;
for nf=1:length(f) %like for loop going through each freq in freqrange
    tn=0:Ts:(NT/f(nf)); %time vector. NT/f(nf) is the amount of time that NF (100) periods takes
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
n0=find(data(:,5)>.5,1,'first'); %find first value in column 5 of data >.5 
%perhaps defines the first value of t by looking for a suitable amplitude to be set as the reference point for
%all waves
t(1:n0-1)=[];
t=t-t(1); %deletes first all other points in t besides initial ref point then shifts t0 and all other t's to start at 0
data(1:n0-1,:)=[]; %clears all the voltage data to align with t0

n0b=find(outputSignalcos>.5,1,'first'); %sets the ref signal to start at .5 too
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
    for m=1:4 %probs each mic

        nta=fix(Nc(n)+.3*(Nc(n+1)-Nc(n)));%nta starting point (sample) for frequency f
        ntb=fix(Nc(n)+.8*(Nc(n+1)-Nc(n))); %end point for frequency f
        
        X = (data(nta:ntb,m)' * data(nta:ntb,5))/length(nta:ntb);
        Y = (data(nta:ntb,m)' * data(nta:ntb,6))/length(nta:ntb);
        Am(n,m) = 2*sqrt(X^2 + Y^2);
        Ph(n,m) = atan2(Y,X);
    end
end

uPh = unwrap(Ph);
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
plot(f,phaseoff);
legend('1','2','3','4')
pause(1)

figure
plot(f,Am);
legend('1','2','3','4')

%% -- Computing tramsmissionn and reflection coeffients --
% disp(['computing tramsmissionn and reflection coeffients...'])

p1=Am(:,1)/c1/m1*m1.*exp(1i*Ph(:,1));
p2=Am(:,2)/c2/m2*m1.*exp(1i*Ph(:,2));
p3=Am(:,3)/c3/m3*m1.*exp(1i*Ph(:,3));
p4=Am(:,4)/c4/m4*m1.*exp(1i*Ph(:,4));

% -- Transfer functions --
H12=p1./p2;
H43=p4./p3;
H32=p3./p2;

% -- sound speed --
c0=344;

% -- Wavenumber --
k=2*pi*f'/c0;

% -- Reflection and transmission coefficients -- 
R1 = (H12.*exp(1i*k*x2) - exp(1i*k*x1)) ./ (exp(-1i*k*x1) - H12.*exp(-1i*k*x2));
R2 = (H43.*exp(-1i*k*x3) - exp(-1i*k*x4)) ./ (exp(1i*k*x4) - H43.*exp(1i*k*x3));
T12 = H32 .* (exp(1i*k*x2) + R1.*exp(-1i*k*x2)) ./ (exp(1i*k*x3) + 1./R2.*exp(-1i*k*x3));

T = T12.*(1-R1./R2)./(1-(T12./R2).^2);
R = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

disp(['done!'])
figure
hold on
plot(f, abs(T).^2)                  %transmission
plot(f, abs(R).^2,'r')              %reflection
plot(f, abs(R).^2+abs(T).^2,'g')    %absorbtion
grid on
ylim([-.5 1.5])
legend('T','R','R+T')

save(filename, 'Ph','Am')

clearvars