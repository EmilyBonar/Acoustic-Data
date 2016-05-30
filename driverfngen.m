function [dataout]=driverfngen(freqrange,amp,ampoff,wave,channels,readpoints, mic_status, filename, data)
s=size(freqrange,2);%number of frequencies being run
s2=size(channels,2);
%dataout=zeros(s,s2+1);%preallocates dataout

fngen.Make = 'AGILENT';%Function generator make
fngen.Address = 'USB0::0x0957::0x4B07::MY53400461::0::INSTR';%USB address of fnggen
%If USB address does not register, unplug usb and plug back in


%% For loop to run for each frequency
for i=1:s
    freq=freqrange(i);%sets current frequency to variable
    disp(['Frequency: ',num2str(freq)])
    dataout(i,:) = InitFnGen(fngen,freq,amp, ampoff,wave,channels,readpoints, mic_status, filename, freqrange);%calls to initialize the function gen
    clc;
end

%% Turn off function generator
%connects to function generator to turn off signal after all frequencies
%have been run
interfaceObj = visa('AGILENT', 'USB0::0x0957::0x4B07::MY53400461::0::INSTR');
GENOBJ = icdevice('agilent_33120a.mdd', interfaceObj);
connect(GENOBJ);
fclose(interfaceObj);
delete(interfaceObj);
GENOBJ = visa(fngen.Make,fngen.Address);
fopen(GENOBJ);
fprintf(GENOBJ,'OUTPUT OFF');
end