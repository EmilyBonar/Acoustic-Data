%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/2', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/1.xlsx', d); %must change to file that you want to save to
sheet = 1;
mic_status = 1;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s', d));
if mic_status == 1
    excelClear(filename_excel, sheet);
end

disp('Loading Data')
datain = load(filename);
datain = datain.dataout;

channels=[1,3];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0627,0.0613];%correction factors for mics 1,2

band = datain{1};
time = datain{2};
volts = datain{3};

for i=1:s
    p(:,i)=volts(:,i)./correction(i);%turn voltage into pressure
end

disp('Calculating FFT')
fourier = fft(p);
figure
plot(abs(fourier))

%% Analysis and Decomposition of Reflection
dataout = decomp(fourier, time, band, mic_status); 
%[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i] 

%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout, mic_status)