function [dataout]=driveroscil(channels,readpoints,freq,trig)
%called by InitFnGen to collect data once the signal is being sent
%Sets parameters for oscilloscope, calls InitOscil to set them, and then
%calls PullData to gather data from oscilloscope.
%Once data is collected, sends back to driverfngen to be to stored in data 
%out which is saved to .mat file after all freqs have been gathered for later analysis
oscil.Make = 'agilent';
oscil.Address = 'USB0::0x2A8D::0x1768::MY55280363::0::INSTR';
oscil.InputBufferSize = 1E8;
oscil.ByteOrder = 'littleEndian';
oscil.ReadPoints = readpoints; % How many points we read out from the oscilloscope,
oscil.ChannelsToRead = channels; 
% oscil.TriggerMode = 'normal';
% oscil.Triggerlevel = 0.5;


oscilobj=InitOscil(oscil,trig);%sets up oscilloscope

%data = PullDataSynch(oscilobj,oscil);%pulls data from oscilloscope
data = PullData(oscilobj,oscil);%pulls data from oscilloscope

data.t=transpose(data.t);%transpose data to make it easier to use
data.V=transpose(data.V);%transpose data to make it easier to use

dataout = cell(1,3);
dataout{1} = freq;
dataout{2} = data.t;
dataout{3} = data.V;

end