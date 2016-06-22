%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/M0P0B2R1-1 Noise, 500 reps', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/M0P0B2R1 Noise, 500 reps.xlsx', d); %must change to file that you want to save to
sheet = 1;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s', d));

excelClear(filename_excel, sheet);

disp('Loading Data')
datain = load(filename);
datain = datain.dataout;

channels=[1,3,4];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0613, 0.0627, 0.0603];%correction factors for mics 1,2

band = datain{1};
time = datain{2};
volts = datain{3};

for i=1:s
    fourier(:,i)=volts(:,i)./correction(i);%turn voltage into pressure
end

%% Analysis and Decomposition of Reflection
dataout = decomp(fourier, time, band); 
%[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i] 

%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout)