%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='SIN'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
%freqrange=[1800:25:1900,1910:20:1990, 2000:5:2020,2021:1:2034 2035:5:2055, 2060:20:2140, 2150:25:2250]; %frequency in Hz
%freqrange=(1800:5:2250); %frequency in Hz
%freqrange=(1500:25:2500); %frequency in Hz
freqrange = 2000;
amp=.25; %amplitude in V
ampoff=0; %amplitude offset in V

%% Parameters for Oscilloscope
channels=[1,3];%what channels to take from
readpoints=8e6*1/2;% number of readpoints to take (oscilloscope window: sampling rate*duration)
%% Data Writing Parameters
d = date;
[s,m1,m2] = mkdir(sprintf('Experimental Data/%s', d)); %create date folder
filename=sprintf('Experimental Data/%s/slightly more loosened foam1 with fork in back in mount3', d); %must change to file that you want to save to
 
data = cell(length(freqrange),3);

%% Running different tests
dataout=driverfngen(freqrange,amp, ampoff,wave,channels,readpoints,data);

%% Save Data
disp('Saving Data')
save(filename, 'dataout')
