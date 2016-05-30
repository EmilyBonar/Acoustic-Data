function [dataout]=driveroscil(channels,readpoints,freq, mic_status, filename, sheet, f)
%called by InitFnGen to collect data once the signal is being sent
%Sets parameters for oscilloscope, calls InitOscil to set them, and then
%calls PullData to gather data from oscilloscope.
%Once data is collected, sends data to decomp to be analyzed.
%Then outputs analyzed data to be written.
oscil.Make = 'agilent';
oscil.Address = 'USB0::0x2A8D::0x1768::MY55280363::0::INSTR';
oscil.InputBufferSize = 1E8;
oscil.ByteOrder = 'littleEndian';
oscil.ReadPoints = readpoints; % How many points we read out from the oscilloscope
oscil.ChannelsToRead = channels;
% oscil.TriggerMode = 'normal';
% oscil.Triggerlevel = 0.5;


[oscilobj,~]=InitOscil(oscil);%sets up oscilloscope

%[dataout, ~] = PullDatatry(oscilobj,oscil);%pulls data from oscilloscope
dataout = PullDataSynch(oscilobj,oscil);%pulls data from oscilloscope      Same results as above, but ~3 sec faster

dataout.t=transpose(dataout.t);%transpose data to make it easier to use
dataout.V=transpose(dataout.V);%transpose data to make it easier to use

%xlswrite('PaulData', [dataout.t(:,1) dataout.V(:,1) dataout.t(:,2) dataout.V(:,2)], find(f == freq))

s=size(channels,2);%number of channels being called
data=zeros(s,1);%preallocates data vector
correction=[0.0613,0.0627];%correction factors for mics 1,2
fs=1/(dataout.t(2,1)-dataout.t(1,1));
%calculations for mics
for i=1:1:s
    p=dataout.V(:,i)./correction(i);%multiply by factor
    HP_P(:,i)=highpass(p,fs);
end

%n = fs/freq*1000;
fourier = fft(HP_P);
phase = angle(fourier);

%% Decomposition of Reflection
[dataout] = decomp(fourier, mic_status, filename, sheet, freq, f);
%[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i]

end