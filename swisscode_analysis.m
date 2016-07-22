% This script measures the transmission and reflection coefficient using 
% the two-port technique. 
%
% Miguel Moleron, ETH, Jun 2016
% 

clear all
%close all
%clc

%% -- Microphone calibration --
c1=0.00639114;
c2=0.00697183;
c3=0.00927487;
c4=0.00800474;

et = load('emptytube');
data = et.data;

%% -- Initialiyze DAQ --
Fs=2e5; % Sample rate for output signal
Ts=1/Fs; %time between samples
f=[100:10:5000]; % frequencies to evaluate
NT=100; % number of periods per frequency point

t=0:Ts:Ts*(fix(Fs/4)-1); % initial waiting time = 0.25 seconds
outputSignalcos=t*0;
outputSignalsin=t*0;
for nf=1:length(f) %like for loop going through each freq in freqrange
    tn=0:Ts:(NT/f(nf)-Ts); %time vector. NT/f(nf) is the amount of time that NF (100) periods takes
    outputSignalcos = [outputSignalcos cos(2*pi*f(nf)*tn)]; %I think these are the lockin ref signals.
    outputSignalsin = [outputSignalsin sin(2*pi*f(nf)*tn)];
    t=[t tn+t(end)];
end

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
%not sure how this shift compares to the actual signal shift
outputSignalcos(1:n0b-1)=[];

% -- Beginning and end of each frequency step --
Nn=NT./f*Fs; %number of samples for each frequency
for n=1:length(Nn)
    Nc(n)=sum(Nn(1:n));
end
Nc=[0 Nc];
clear n Nn %sums up all the elements of Nn [1 1+1 1+2+3...] then adds a 0 to the begining

%% -- Calculate amplitudes and phases from time signals --

disp(['calculating amplitudes and phases from time signals...'])
for n=1:length(f) %like or freq in freqrange forloop
    for m=1:4 %probs each mic

        nta=fix(.3*(Nc(n+1)));
        ntb=fix(.8*(Nc(n+1)));
        
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
p12=Am(3,:)/c3.*exp(j*Ph(3,:));
p11=Am(4,:)/c4.*exp(j*Ph(4,:));
p21=Am(1,:)/c1.*exp(j*Ph(1,:));
p22=Am(2,:)/c2.*exp(j*Ph(2,:));

% -- Transfer functions --
H121=p12./p11;
H221=p22./p21;
H2111=p21./p11;

% -- sound speed --
c0=344;

% -- Wavenumber --
k=2*pi*f/c0;

% -- Distances --
x12=0;
x11=x12+0.015;
x21=x11+0.15;
x22=x21+0.015;

% -- Reflection and transmission coefficients -- 
R1 = (H121.*exp(j*k*x11) - exp(j*k*x12)) ./ (exp(-j*k*x12) - H121.*exp(-j*k*x11));
R2 = (H221.*exp(-j*k*x21) - exp(-j*k*x22)) ./ (exp(j*k*x22) - H221.*exp(j*k*x21));
T12 = H2111 .* (exp(j*k*x11) + R1.*exp(-j*k*x11)) ./ (exp(j*k*x21) + 1./R2.*exp(-j*k*x21));

T = T12.*(1-R1./R2)./(1-(T12./R2).^2);
R = (R1 - T12.^2./R2)./(1-(T12./R2).^2);

disp(['done!'])
figure
hold on
plot(f, abs(T).^2)
plot(f, abs(R).^2,'r')
plot(f, 1-abs(R).^2-abs(T).^2,'g')
grid on
%ylim([-0.1 1.1])