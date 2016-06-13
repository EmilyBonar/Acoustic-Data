function [OSCOBJ, errtest] = InitOscil(oscil)
%called by driveroscil to set up the oscilloscope to prepare for data
%collection
display('Initializing Oscilloscope')
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

%
% Finds the Agilent DSO on USB and initializes it for data-taking
%

OSCOBJ = visa(oscil.Make,oscil.Address);
% Set the buffer size
OSCOBJ.InputBufferSize = oscil.InputBufferSize; % Do I need to make this bigger?
% Set the timeout value
OSCOBJ.Timeout = 10;
% Set the Byte order
OSCOBJ.ByteOrder = 'littleEndian';
% %set trigger mode
% OSCOBJ.TriggerMode=oscil.TriggerMode;
% %set Triggerlevel (Volts)
% OSCOBJ.Triggerlevel=oscil.Triggerlevel;
% Open the connection
fopen(OSCOBJ);

fprintf(OSCOBJ,':TIMEBASE:MODE MAIN');
% Set up acquisition type and count.
fprintf(OSCOBJ,':ACQUIRE:TYPE NORMAL');%was NORMAL
fprintf(OSCOBJ,':ACQUIRE:COUNT 2');
% fprintf(OSCOBJ, 'TriggerMode normal');
% fprintf(OSCOBJ, 'Triggerlevel 1');
%fprintf(OSCOBJ, ':TRIGGER:EDGE:SLOPE POSITIVE');
% fprintf(OSCOBJ,'*IDN?');
% oscil.TriggerMode = 'normal';
% oscil.Triggerlevel = 0.5;
errtest = 0;
display('Oscilloscope Initialized')
end