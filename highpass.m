function HP_P=highpass(p,fs)

fc=1.5e3;
fn=1/(sqrt(2))*fs;


[b,a]=butter(6,fc/fn,'high');
HP_P=filtfilt(b,a,p(:,1));

end
