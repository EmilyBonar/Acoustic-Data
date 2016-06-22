function [dataout]=driverfngen(band,amp,ampoff,wave,channels,readpoints, reps)
s2=size(channels,2);

fngen.Make = 'AGILENT';%Function generator make
fngen.Address = 'USB0::0x0957::0x4B07::MY53400461::0::INSTR';%USB address of fnggen
%If USB address does not register, unplug usb and plug back in

dataout = cell(1,3);
dataout{3} = zeros(readpoints,s2);
for x = 1:reps
    sprintf('Run %i out of %i',x, reps)
    d = InitFnGen(fngen,band,amp,ampoff,wave,channels,readpoints);%calls to initialize the function gen
    dataout{1} = d{1};
    dataout{2} = d{2};
    dataout{3} = dataout{3} + 1/reps.*d{3};
    clc
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