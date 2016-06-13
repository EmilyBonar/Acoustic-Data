function dataout = PullData(oscilobj,oscil)
n = 1;
% User defined constants
GLOBAL_TIMEOUT = 10;
TIME_TO_TRIGGER = 10; % Time in seconds; How long should the script wait for the scope to trigger?
% Set global timeout for the scope; can rest this as needed for specific
% commands (before and after)
oscilobj.Timeout = GLOBAL_TIMEOUT;

% Always stop scope before setting it up
fprintf(oscilobj, ':STOP');

% Clear the scope registers; wait for *OPC to come back
query(oscilobj, '*CLS;*OPC?');

%% Find timebase and acquisition mode settings for proper synchronization

TimeRange    = str2double(query(oscilobj,':TIMebase:RANGe?'));
TimePosition = str2double(query(oscilobj,':TIMebase:POSition?'));
TrigHoldOff  = str2double(query(oscilobj,':TRIGger:HOLDoff?'));
AcqType      = deblank(query(oscilobj, ':ACQuire:TYPE?'));

if strcmpi(AcqType, 'AVER') or strcmpi(AcqType, 'AVERage')
    Acq_Type_Err = MException('myscript:error','This synchronization method will not work for average acquisition mode.  Properly closing scope and aborting.');
    %% Properly close scope
    clrdevice(oscilobj);
    fclose(oscilobj);
    delete(oscilobj);
    clear oscilobj;
    throw(Acq_Type_Err)
end

% Calculate time to wait for acqusition to complete  by gross overestimation; ensure at least 10 seconds
ACQ_TIME_OUT = TimeRange*2.0 + abs(TimePosition)*2.0 + (TIME_TO_TRIGGER)*1.1 + (TrigHoldOff)*1.1;
if  ACQ_TIME_OUT < 10.0
    ACQ_TIME_OUT = 10;
end

%% Acquire setup

% Define "mask" bits and completion criterion.
% Mask bits for Run state in the Operation Status Condition (and Event) Register
     % This can be confusing.  In general, refer to Programmer's Guide chapters on Status Reporting, and Synchronizing Acquisitions
     % Also see the annotated screenshots included with this sample script.
RUN_BIT  = 3; % The run bit is the 3rd bit.  If it is high, the scope is in a RUN state, i.e. not done.
RUN_MASK = 2^RUN_BIT;  % This basically means:  2^3 = 8 ; this is used later to
    % "unmask" the result of the Operation Status Event Register as there is no direct access to the RUN bit.

% Completion criteria
ACQ_DONE = 0; % Means the scope is stopped, i.e. the acquisition is done
ACQ_NOT_DONE = 8; %  This is the 4th bit of the Operation Status Condition (and Event) Register.  The registers are binary and start counting at zero, thus the 4th bit is bit number 3, and 2^3 = 8.
    % This is either High (running = 8) or low (stopped and therefore done with acquisition = 0).

%% Acquire

disp 'Acquiring signal(s)...'
fprintf(oscilobj, '*CLS'); % Clear all registers; sets them to 0; This could be concatenated with :SINGle command two lines below line to speed things up a little like this -> fprintf(oscilobj, ':SINGle;*CLS')

Start_Time = now;
pause(4)
fprintf(oscilobj, ':SINGle');

% Immediately ask scope if it is done with the acquisition via the Operation Status Condition (not Event) Register.
Status = str2num(query(oscilobj, ':OPERegister:CONDition?')); 
    % The Condition register reflects the CURRENT state, while the EVENT register reflects the first event that occurred since it was cleared or read, thus the CONDTION register is used.
Acq_State = bitand(Status,RUN_MASK); % Bitwise AND of the Status and RUN_MASK.  This exposes ONLY the 3rd bit, which is either High (running = 8) or low (stopped and therefore done with acquisition = 0)

while Acq_State == ACQ_NOT_DONE & ((now - Start_Time)*24*3600 <= ACQ_TIME_OUT) % This loop is never entered if the acquisition completes immediately; Exits if Status == 1 or Acq_Time_Out exceeded
    pause(0.1) % Pause 100 ms to prevent excessive queries
    Status = str2num(query(oscilobj, ':OPERegister:CONDition?'));
    Acq_State = bitand(Status,RUN_MASK);
end

if Acq_State == ACQ_DONE % Acquisition fully completed
    disp 'Signal acquired.'
else % Acquisition failed for some reason
    disp 'Max wait time to trigger and acquire data exceeded.'
    disp 'This can happen if there was not enough time to arm the scope, there was no trigger event, or the scope did not finish acquiring.'
    disp 'Visually check the scope for a trigger, adjust settings accordingly.'
    
    clrdevice(oscilobj); % Clear scope communications interface
    fprintf(oscilobj, ':STOP') % Stop the scope
    fclose(oscilobj); % Close communications interface to scope
    delete(oscilobj); 
    clear oscilobj; 
    Synch_Err = MException('myscript:error','Properly closing scope connection and exiting script.');
    throw(Synch_Err)
end

fprintf(oscilobj,':WAVeform:POINts:MODE Normal')
fprintf(oscilobj,':WAVeform:UNSigned 0');
fprintf(oscilobj,':WAVEFORM:FORMAT WORD');
fprintf(oscilobj,':WAVEFORM:BYTEORDER LSBFirst');

%% Preamble
% Maximum value storable in a INT16


disp('Acquiring Preamble')
pause(.1)
%  split the preambleBlock into individual pieces of info
preambleBlock = query(oscilobj,':WAVEFORM:PREAMBLE?');
preambleBlock = regexp(preambleBlock,',','split');
maxVal = 2^16;
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
waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);
waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin) ;        % V
waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10;  % seconds
waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds


%% Seperate Channel Data
disp('Separating Data')
for chanindex = oscil.ChannelsToRead
    inputstring = [':WAVEFORM:SOURCE CHAN', num2str(chanindex)];
    disp(inputstring);
    fprintf(oscilobj,inputstring);
    
    fprintf(oscilobj,':WAVeform:DATA?');
    % read back the BINBLOCK with the data in specified format and store it in
    % the waveform structure. FREAD removes the extra terminator in the buffer
    
    wave.RawData = binblockread(oscilobj,'int16'); 
    fread(oscilobj,1);
    instrumentError = query(oscilobj,':SYSTEM:ERR?');
    while ~isequal(instrumentError,['+0,"No error"' char(10)])
        disp(['Instrument Error: ' instrumentError]);
        instrumentError = query(oscilobj,':SYSTEM:ERR?');
        pause(.1)
    end
    
    % Generate X & Y Data
     wave.XData = (waveform.XIncrement.*(1:length(wave.RawData))) - waveform.XIncrement+waveform.XOrigin;
     wave.YData = (waveform.YIncrement.*(wave.RawData - waveform.YReference)) + waveform.YOrigin;
     %have shown that it's taking increases and decreases in 8 bit depth
     %or something idk, y resolution is pretty grainy like .004V when
     %sampling at 4million can see wierd up down .004 jumps every frew
     %samples most likely due to floating point rounding or something of
     %that nature. deemed not critical for data analysis for now.
%    plot(wave.XData,wave.YData)
     
    dataout.t(n,:) = wave.XData;
    dataout.V(n,:) = wave.YData;
    n = n+1;
    clear wave
end

clear waveform

%% Properly close scope
clrdevice(oscilobj); % Clear scope communications interface
fclose(oscilobj); % Close communications interface to scope
delete(oscilobj); 
clear oscilobj; 

disp 'Done.'

end

%% Explanation of this synchronization method

% Benefits of this method:
        % Don't have to worry about interface timeouts
        % Easy to expand to know when scope is armed, and triggered
% Drawbacks of this method:
    % Slow
    % Does NOT work for Average Acquisition mode
        % The :SINGle does not do a complete average, and counting triggers in :RUN is much too slow
    % Can't be used effectively for synchronizing math functions
        % It can be done by applying an additional hard coded wait after the acquisition is done.  At least 200 ms is suggested, more may be required.
    % Still need some maximum timeout (here ACQ_TIME_OUT), ideally, or the script will sit in the while loop forever if there is no trigger event
    % Max time out (here ACQ_TIME_OUT) must also account for time to arm the scope and finish the acquisition
% How it works:
    % Pretty well explained in line; see annotated screenshot. Basically:
        % What really matters is the RUN bit in the Operation Condition (not Event) Register.  This bit changes based on the scope state.
        % If the scope is running, it is high (8), and low (0) if it is stopped.
        % The only way to get at this bit is with the :OPERation:CONDition? query.  The Operation Condition Register can reflect states
        % for other scope properties, for example, if the scope is armed, thus it can produce values other than 0 (stopped) or 8 (running).
        % To handle that, the result of :OPERation:Condition? is logically ANDed (& in Python) with an 8.  This is called "unmasking."
        % Here, the "unmasking" is done in the script.  On the other hand, it is possible to "mask" which bits get passed to the
        % summary bit to the next register below on the instrument itself.  However, this method it typically only used when working with the Status Byte,
        % and not used here.
        % Why 8 = running = not done?
            % The Run bit is the 4th bit of the Operation Status Condition (and Event) Registers.
            % The registers are binary and start counting at zero, thus the 4th bit is bit number 3, and 2^3 = 8, and thus it returns an 8 for high and a 0 for low.
        % Why the CONDITION and NOT the EVENT register?
            % The Condition register reflects the CURRENT state, while the EVENT register reflects the first event that occurred since it was cleared or read,
            % thus the CONDTION register is used.