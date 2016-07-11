%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='SMS'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
%freqrange=[1800:20:1900,1910:10:1990, 2000:2:2050, 2060:10:2140, 2150:20:2250]; %frequency in Hz
%freqrange=(2000); %frequency in Hz
cutoff=4000; %frequency in Hz
amp=1.5; %amplitude in V
ampoff=0; %amplitude offset in V
reps = 1; %how many runs will be averaged together

t = 0:.0002:1;
u = zeros(size(t));
for k = 1:cutoff
    u = u + amp*cos(2*pi*(k*1)*t+(-k*(k-1)*pi/cutoff));
end
convertToArb(u,1,'wave');

%% Parameters for Oscilloscope
channels=[1,3,4];%what channels to take from
readpoints=2e6;% number of readpoints to take (oscilloscope window: sampling rate*duration)
%readpoints=64516; %how is this being used?
%% Data Writing Parameters
d = date;
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s', d)); %create date folder
filename=sprintf('Experimental Data/%s/M0P0R1-1 Multisine', d); %must change to file that you want to save to

%% Running different tests
dataout=driverfngen(u,wave,cutoff, channels,readpoints, reps);

%% Save Data
save(filename, 'dataout')
