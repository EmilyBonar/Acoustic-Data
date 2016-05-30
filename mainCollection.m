%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='SIN'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
freqrange=[1800:20:1900,1910:10:1990, 2000:2:2050, 2060:10:2140, 2150:20:2250]; %frequency in Hz
%freqrange=(2000); %frequency in Hz
%freqrange=(1500:25:2500); %frequency in Hz
amp=.08; %amplitude in V
ampoff=0; %amplitude offset in V

sweepstart= 1900; %start of sweep frequency
sweepend= 2200; % end of sweep frequency
sweeptime=6; %sweeptime in seconds

%% Parameters for Oscilloscope
channels=[1,3];%what channels to take from
readpoints=2e6*2;% number of readpoints to take (oscilloscope window: sampling rate*duration)

%% Data Writing Parameters
d = date;
[s,m1 m2] = mkdir(sprintf('Experimental Data/%s', d)); %create date folder
filename=sprintf('Experimental Data/%s/1r', d); %must change to file that you want to save to
sheet=1; %sheet of excel file to write to
mic_status = 1; %1 if reflection incidence, 2 if reflection transmission

data = cell(length(freqrange),3);

%% Running different tests
dataout=driverfngen(freqrange,amp, ampoff,wave,channels,readpoints, mic_status, filename, data);

%% Save Data
save(filename, 'dataout')
