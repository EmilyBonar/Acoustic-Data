%Program for Acoustic testing
clear all;
%close all;
clc;
%% Parameters for Function Generator
wave='SIN'; %waveform desired
%%Can set wave to [SINusoid,SQUare,RAMP,NOISe,DC,SINC,EXPRise,EXPFall,CARDiac,GAUSsian,ARBitrary]
%freqrange=[1800:10:1899,1900:10:2000, 2001:2:2049, 2050:10:2150, 2151:10:2250]; %frequency in Hz
freqrange=(2000); %frequency in Hz
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
filename=sprintf('Experimental Data/%s/1.xlsx', d); %must change to excel file that you want to save to
sheet=1; %sheet of excel file to write to
mic_status = 1; %1 if reflection incidence, 2 if reflection transmission

%% Clear Excel sheet to be written to
if mic_status == 1
    excelClear(filename, sheet);
end

%% Running different tests
[dataout]=driverfngen(freqrange,amp, ampoff,wave,channels,readpoints, mic_status, filename, sheet);
%[dataout]=driversweep(amp,ampoff,sweepstart,sweepend,sweeptime,wave,channels,readpoints,filename,sheet, mic_status)

%% Write to Excel
excelwritedecomp(filename, sheet, dataout, mic_status)
