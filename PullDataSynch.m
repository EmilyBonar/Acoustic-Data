function dataout = PullDataSynch(oscilobj,oscil)
n = 1;
GLOBAL_TIMEOUT = 10;
TIME_TO_TRIGGER = 10; % Time in seconds; How long should the script wait for the scope to trigger?
%% Find timebase settings for proper synchronization

TimeRange    = str2double(query(oscilobj,':TIMebase:RANGe?'));
TimePosition = str2double(query(oscilobj,':TIMebase:POSition?'));
TrigHoldOff  = str2double(query(oscilobj,':TRIGger:HOLDoff?'));

% Calculate time to wait for acqusition to complete  by gross overestimation; ensure at least 10 seconds
ACQ_TIME_OUT = TimeRange*2.0 + abs(TimePosition)*2.0 + (TIME_TO_TRIGGER)*1.1 + (TrigHoldOff)*1.1;
if  ACQ_TIME_OUT < 10.0
    ACQ_TIME_OUT = 10;
end
pause(2.2)

%% Acquire
fprintf(oscilobj,':WAVeform:UNSigned 0');
fprintf(oscilobj,':WAVEFORM:FORMAT WORD');
fprintf(oscilobj,':WAVEFORM:BYTEORDER LSBFirst');

% Reset the lastwarn to null, to properly handle a possible timeout
lastwarn('', '');

disp 'Acquiring signal(s)...'

% Change isntumetn timeout to cover all of the acqusition.
oscilobj.Timeout = ACQ_TIME_OUT; 
% If doing repeated acquisitions, this should be done BEFORE the loop, and
% changed again after the loop if the goal is to achieve best throughput.

query(oscilobj, ':DIGitize;*OPC?'); % Acquire the signal(s) with :DIGItize (blocking) and wait until *OPC? comes back with a one.

% Check for and handle a timeout
[warnStr, warnId] = lastwarn; % Get last warning 
if strcmpi(warnStr, 'Unsuccessful read: VISA: A timeout occurred')
    % If you are here, then a timeout occurred on read, indicating the
    % acquistion did not finish in the time out

    disp 'Acquisition timed out.'
    disp 'Properly closing scope and aborting script.'
    clrdevice(oscilobj) % clear scope; unlocks the bus as :DIGitize is blocking
    fprintf(oscilobj, '*CLS');
    % disconnect from scope
    fclose(oscilobj);
    delete(oscilobj);
    clear oscilobj;

    % Throw an MException, in effect treating the warning as an error
    TimeOutExeption = MException('myscript:error','Acqusition timed out due to no trigger, or improper setup causing no trigger, or too short of a time out.');
    throw(TimeOutExeption)
else
    disp 'Signal acquired!'
end

%% Preamble
% Maximum value storable in a INT16
maxVal = 2^16;

%  split the preambleBlock into individual pieces of info
preambleBlock = query(oscilobj,':WAVEFORM:PREAMBLE?');
preambleBlock = regexp(preambleBlock,',','split');

% store all this information into a waveform structure for later use
waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
waveform.Type = str2double(preambleBlock{2});
waveform.Points = str2double(preambleBlock{3});
waveform.Count = str2double(preambleBlock{4});      % This is always 1
waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
waveform.XReference = str2double(preambleBlock{7});
waveform.YIncrement = str2double(preambleBlock{8}); % V
waveform.YOrigin = str2double(preambleBlock{9});
waveform.YReference = str2double(preambleBlock{10});
waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

%% Seperate Channel Data
for chanindex = oscil.ChannelsToRead
    inputstring = [':WAVEFORM:SOURCE CHAN', num2str(chanindex)];
    disp(inputstring);
    fprintf(oscilobj,inputstring);
    
    fprintf(oscilobj,':WAVeform:DATA?');%may be causing timeout error. try to read this back
    % read back the BINBLOCK with the data in specified format and store it in
    % the waveform structure. FREAD removes the extra terminator in the buffer
    
    wave.RawData = binblockread(oscilobj,'int16'); 
    fread(oscilobj,1);
    instrumentError = query(oscilobj,':SYSTEM:ERR?');
    while ~isequal(instrumentError,['+0,"No error"' char(10)])
        disp(['Instrument Error: ' instrumentError]);
        instrumentError = query(oscilobj,':SYSTEM:ERR?');
        pause(.1)
        errdata = 1;
    end
    
    % Generate X & Y Data
    wave.XData = (waveform.XIncrement.*(1:length(wave.RawData))) - waveform.XIncrement+waveform.XOrigin;
    wave.YData = (waveform.YIncrement.*(wave.RawData - waveform.YReference)) + waveform.YOrigin;

    dataout.t(n,:) = wave.XData;
    dataout.V(n,:) = wave.YData;
    n = n+1;
    clear wave
end

clear waveform
% Reset the scope timeout
oscilobj.Timeout = GLOBAL_TIMEOUT;
% Note: If doing repeated acquisitions, this should be done AFTER the loop, and
% changed again after the loop if the goal is to achieve best throughput.

end