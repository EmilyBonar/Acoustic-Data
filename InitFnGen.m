function [dataout] = InitFnGen(fngen,freq,amp,ampoff,wave,channels,readpoints)
%Called from driverfngen, sets up the function generator, turns on signal,
%and then proceeds to call driveroscil to take data
newobjs = instrfind;

%If there are any existing objects
if (~isempty(newobjs))
    %close the connection to the instrument
    fclose(newobjs);
    %and free up the object resources
    delete(newobjs);
end
instrreset;

%Remove the object list from the workspace.
clear newobjs;

%try
disp('Initializing Function Generator')

% Create a VISA-USB object.
interfaceObj = visa(fngen.Make, fngen.Address);

% Create the VISA-USB object if it does not exist
% Create a device object.
GENOBJ = icdevice('agilent_33120a.mdd', interfaceObj);

% Connect device object to hardware.
connect(GENOBJ);

% Execute device object function(s).
%devicereset(GENOBJ);
fclose(interfaceObj);
delete(interfaceObj);
GENOBJ = visa(fngen.Make,fngen.Address);
fopen(GENOBJ);


fprintf(GENOBJ,'OUTPUT OFF'); % turn on channel 1 output
pause(.5)
%Variable setting
fprintf(GENOBJ, ['SOURce1:FUNCtion ',num2str(wave)]);%set waveform to desired wave
fprintf(GENOBJ, ['SOURce1:FREQuency ',num2str(freq)]);%set source frequency
fprintf(GENOBJ, ['SOURce1:VOLTage ',num2str(amp)]); %set voltage of signal
fprintf(GENOBJ, ['SOURce1:VOLTage:OFFS ',num2str(ampoff)]); %set voltotage offset
fprintf(GENOBJ,'OUTPUT ON'); % turn on channel 1 output

[dataout]=driveroscil(channels,readpoints, freq);%calls driveroscil to collect data

display('Function Generator Finished')
end