function [dataout] = InitFnGen(fngen,band,amp, ampoff,wave,channels,readpoints)
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
devicereset(GENOBJ);
fclose(interfaceObj);
delete(interfaceObj);
GENOBJ = visa(fngen.Make,fngen.Address);
fopen(GENOBJ);

%Variable setting
% fprintf(GENOBJ, ['SOURce1:FUNCtion ',num2str(wave)]);%set waveform to desired wave
% fprintf(GENOBJ, ['SOURce1:VOLTage ',num2str(amp)]); %set voltage of signal
% fprintf(GENOBJ, ['SOURce1:VOLTage:OFFS ',num2str(ampoff)]); %set voltotage offset
% fprintf(GENOBJ,'OUTPUT ON'); % turn on channel 1 output
fprintf(GENOBJ, sprintf('SOURce1:FUNCtion:NOISe:BANDwidth %s', num2str(band)));
fprintf(GENOBJ, sprintf('SOURce1:APPLy:%s 2e4,%s,%s', num2str(wave), num2str(amp),num2str(ampoff)));

[dataout]=driveroscil(channels,readpoints);%calls driveroscil to collect data

display('Function Generator Finished')
end