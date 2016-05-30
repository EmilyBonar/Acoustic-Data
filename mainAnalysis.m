%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/2r', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/1.xlsx', d); %must change to file that you want to save to
sheet = 2;

datain = load(filename);

mic_status = 1;

channels=[1,3];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0613,0.0627];%correction factors for mics 1,2

dataout = zeros(length(datain.dataout), 12);

for x = 1:length(datain.dataout)
    pos = x;
    freq = datain.dataout{x,1};
    time = datain.dataout{x,2};
    volts = datain.dataout{x,3};
    
    fs=1/(time(2,1)-time(1,1));
    %calculations for mics
    for i=1:1:s
        p=volts(:,i)./correction(i);%multiply by factor
        HP_P(:,i)=highpass(p,fs);
    end

    %n = fs/freq*1000;
    fourier = fft(HP_P);

    %% Analysis and Decomposition of Reflection
    dataout(x,:) = decomp(fourier, mic_status, filename, sheet, freq, pos);
    %[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i]
end

%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout, mic_status)