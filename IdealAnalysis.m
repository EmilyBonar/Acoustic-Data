% function IdealAnalysis(filename,filename_excel,sheet)

%Program for Acoustic Analysis
clear all;
%close all;
clc;

d = date;
filename=sprintf('Experimental Data/%s/Ideal4', d); %must change to file that you want to load from
filename_excel=sprintf('Experimental Data/%s/Ideal.xlsx', d); %must change to file that you want to save to
sheet = 4;
correct = 0;

[s,m1, m2] = mkdir(sprintf('Experimental Data/%s/', d));

disp('Loading Data')
datain = load(filename);
datain = datain.dataout;

channels=[1,3];%what channels to take from
s=size(channels,2);%number of channels being called
correction=[0.0627, 0.0613];%correction factors for mics 1,2
correction = [correction correction];

dataout = zeros(length(datain), 9); 

fcount = size(datain);

p=zeros(fcount(1,1),fcount(1,2)-1);
pNew=zeros(fcount(1,1),fcount(1,2)-1);
for x = 1:fcount(1)

    pos = x;
    freq = datain{x,1};
    freqrange(x) = freq;
    time = datain{x,2};
   
    fs=1/(time(2)-time(1)); %sample rate
    t=length(time)/fs; %individual run duration
    freqres= 1/t;
    
    volts = datain{x,3};
    
    N=length(volts); %number of samps or aka fft size
    ovsamp=fs/freq; %oversampling factor, Nyguest theorem requires a factor of at least 2, we need at least 16 for our set up

    disp('Calculating FFT')
    fourier = fft(volts);
    
    %% Analysis and Decomposition of Reflection
    dataout(x,:) = decomp(fourier, freq, correct);
    %[freq, real(H21_1),imag(H21_1),real(H21_2),imag(H21_2), real(H11_21),imag(H11_21), R, T]
end
%% Write to Excel
excelwritedecomp(filename_excel, sheet, dataout)
% end