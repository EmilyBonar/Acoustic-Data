function [dataout] = InitFnGen(fngen,u,wave,channels,readpoints)
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

% % Create a VISA-USB object.
% interfaceObj = visa(fngen.Make, fngen.Address);
% 
% % Create the VISA-USB object if it does not exist
% % Create a device object.
% GENOBJ = icdevice('agilent_33120a.mdd', interfaceObj);
% 
% % Connect device object to hardware.
% connect(GENOBJ);

% % Execute device object function(s).
% %devicereset(GENOBJ);
% fclose(interfaceObj);
% delete(interfaceObj);
% 
GENOBJ = visa(fngen.Make,fngen.Address);
set(GENOBJ, 'OutputBufferSize', 65000*4);
fopen(GENOBJ);

fprintf(GENOBJ, sprintf('OUTPUT OFF'));
pause(.5);

%Variable setting
%fprintf(GENOBJ, sprintf('SOURce1:DATA:ARBitrary %s, %s', wave, 'wave.arb'));
fprintf(GENOBJ, sprintf('SOURce1:FUNC:ARB wave.arb'));

%fprintf(GENOBJ, sprintf('SOURce1:APPLy:%s 2e4,%s,%s', num2str(wave), num2str(amp),num2str(ampoff)));
[dataout]=driveroscil(channels,readpoints);%calls driveroscil to collect data

display('Function Generator Finished')
end