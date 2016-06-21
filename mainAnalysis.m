% function mainAnalysis(filename,filename_excel,sheet, mic_status)

%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/M0P0B2R4-1E2', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/M0P0B2R4E2.xlsx', d); %must change to file that you want to save to
sheet = 1;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));
excelClear(filename_excel, sheet);

disp('Loading Data')
datain = load(filename);
datain = datain.dataout;

channels=[1,3,4];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0627, 0.0613, 0.0603];%correction factors for mics 1,2

dataout = zeros(length(datain), 12); 

fcount = size(datain);
for x = 1:fcount(1)

    pos = x;
    freq = datain{x,1};
    time = datain{x,2};
    volts = datain{x,3};
    fprintf('Frequency: %d\n',freq)

    fs=1/(time(2,1)-time(1,1));
    for i=1:s
        p(:,i)=volts(:,i)./correction(i);%turn voltage into pressure
    end
    %
    disp('Calculating FFT')
    fourier = fft(p);
    %plot(abs(fourier))
    
    %% Analysis and Decomposition of Reflection
    [dataout(x,:)] = decomp(fourier, freq); 
    %[f S11 S12r S12i S22 PiPiC PrPrC PtPtC R T H12r H12i] 
end

%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout)
% end