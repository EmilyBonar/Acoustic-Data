%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/3', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/2.xlsx', d); %must change to file that you want to save to
sheet = 1;
mic_status = 1;

if mic_status == 1
    excelClear(filename_excel, sheet);
end

datain = load(filename);
datain = datain.dataout;

channels=[1,3];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0613,0.0627];%correction factors for mics 1,2

dataout = zeros(length(datain), 12);

for x = 1:length(datain)
    pos = x;
    freq = datain{x,1};
    time = datain{x,2};
    volts = datain{x,3};

    for i=1:s
        p(:,i)=volts(:,i)./correction(i);%turn voltage into pressure
    end

    fourier = fft(p);

    %% Analysis and Decomposition of Reflection
    dataout(x,:) = decomp(fourier, mic_status, filename, sheet, freq, pos);
    %[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i]
end

%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout, mic_status)