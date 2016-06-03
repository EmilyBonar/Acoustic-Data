%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/1', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/1.xlsx', d); %must change to file that you want to save to
sheet = 4;
mic_status = 1;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s', d));
if mic_status == 1
     excelClear(filename_excel, sheet);
end

datain = load(filename);
datain = datain.dataout;

channels=[1,3];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0627,0.0613];%correction factors for mics 1,2

dataout = zeros(length(datain), 12); 

fcount = size(datain);
% for x = 1:fcount(1)
for x = 1:1
    pos = x;
    freq = datain{x,1};
    time = datain{x,2};
    volts = datain{x,3};

    for i=1:s
        p(:,i)=volts(:,i)./correction(i);%turn voltage into pressure
    end
    
    fourier = fft(p);

    %The block below is code for greating a spectrogram
    fs=1/(time(2)-time(1));
   window=hamming(512);
   nfft=1024;
   noverlap=256;
   [S, F, T, P] = spectrogram(volts(:,1), window, noverlap, nfft, fs, 'yaxis');
   surf(T, F, 10*log10(P), 'edgecolor', 'none'); axis tight;view(0,90);
   colormap(hot);
   set(gca, 'clim', [-80 -30]);
   xlabel('time'); ylabel('Frequency');
   
   
    %% Analysis and Decomposition of Reflection
    dataout(x,:) = decomp(fourier, mic_status, filename, sheet, freq, pos); 
    %[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i] 
end
%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout, mic_status)