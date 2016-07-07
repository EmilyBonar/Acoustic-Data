%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='SIN'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
freqrange=[1800:25:1900,1910:20:1970,1975:5:2000,2001:2:2039, 2040:5:2055, 2060:20:2140, 2150:25:2300]; %frequency in Hz
%freqrange=(2010:.5:2040); %frequency in Hz
freqrange=[1500:25:1900,1920:20:1960,1965:5:1999,2000:2:2024, 2025:1:2039, 2040:5:2055, 2060:20:2140, 2150:25:2800]; %frequency in Hz
%freqrange = [1000:10:3000];

amp=.23; %amplitude in V
ampoff=0; %amplitude offset in V

%% Parameters for Oscilloscope
channels=[1,3,4];%what channels to take from
readpoints=4e6*1;% number of readpoints to take (oscilloscope window: sampling rate*duration)
%% Data Writing Parameters
d = date;
[s,m1,m2] = mkdir(sprintf('Experimental Data/%s', d)); %create date folder
filename=sprintf('Experimental Data/%s/M1P0R3-1T', d); %must change to file that you want to save to
 
data = cell(length(freqrange),3);

%% Running different tests
dataout=driverfngen(freqrange,amp, ampoff,wave,channels,readpoints,data);

%% Save Data
disp('Saving Data')
save(filename, 'dataout')
