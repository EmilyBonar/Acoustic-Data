%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='NOISe'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
%freqrange=[1800:20:1900,1910:10:1990, 2000:2:2050, 2060:10:2140, 2150:20:2250]; %frequency in Hz
%freqrange=(2000); %frequency in Hz
band=25000; %frequency in Hz
amp=1.5; %amplitude in V
ampoff=0; %amplitude offset in V
reps = 5; %how many runs will be averaged together

%% Parameters for Oscilloscope
channels=[1,3];%what channels to take from
readpoints=2e6*2;% number of readpoints to take (oscilloscope window: sampling rate*duration)
%readpoints=64516; %how is this being used?
%% Data Writing Parameters
d = date;
[s,m1, m2] = mkdir(sprintf('Experimental Data/%s', d)); %create date folder
filename=sprintf('Experimental Data/%s/2', d); %must change to file that you want to save to

%% Running different tests
dataout=driverfngen(band,amp, ampoff,wave,channels,readpoints, reps);

%% Save Data
save(filename, 'dataout')
