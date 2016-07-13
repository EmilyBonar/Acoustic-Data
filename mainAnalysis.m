% function mainAnalysis(filename,filename_excel,sheet, mic_status)

%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
reflection=sprintf('Experimental Data/%s/M0P0R1-1R', d); %must change to file that you want to load from
transmission=sprintf('Experimental Data/%s/M0P0R1-1T', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/M0P0R1.xlsx', d); %must change to file that you want to save to
sheet = 1;
correct = 1;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));

disp('Loading Data')
datainr = load(reflection);
datainr = datainr.dataout;

dataint = load(transmission);
dataint = dataint.dataout;

channels=[1,3,4];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0627, 0.0613];%correction factors for mics 1,2
correction = [correction correction];

dataout = zeros(length(datainr), 9); 

fcount = size(datainr);
for x = 1:fcount(1)

    pos = x;
    freq = datainr{x,1};
    time = datainr{x,2};
    voltsr = datainr{x,3};
    voltsr = voltsr(:,1:2);
    
    voltst = dataint{x,3};
    voltst = voltst(:,1:2);
    
    volts = [voltsr voltst];
    fprintf('Frequency: %d\n',freq)

    temp = volts(1:60,1);
    [m,i] = min(temp);

    volts = volts(i:end,:);

    disp('Calculating FFT')
    fourier = fft(volts);
    
    %% Analysis and Decomposition of Reflection
    dataout(x,:) = decomp(fourier, freq, correct);
    %[freq, real(H21_1),imag(H21_1),real(H21_2),imag(H21_2), real(H11_21),imag(H11_21), R, T]
end
%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout)
% end