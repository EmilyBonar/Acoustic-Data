mic1data='Mic 1 Position 1';
mic2data='Mic 2 Position 1';
mic3data='Mic 3 Position 1';
mic4data='Mic 4 Position 1';

f=[1500:2:2500]; % frequencies to evaluate

c1=0.00425;
c2=0.00386;
c3=0.00402;
c4=0.00397;

mic1=load(mic1data);
amp1=mic1.Am(:,1);
Ph1=mic1.Ph(:,1);

mic2=load(mic2data);
amp2=mic2.Am(:,2);
Ph2=mic2.Ph(:,2);

mic3=load(mic3data);
amp3=mic3.Am(:,3);
Ph3=mic3.Ph(:,3);

mic4=load(mic4data);
amp4=mic4.Am(:,4);
Ph4=mic4.Ph(:,4);

m1 = mean(amp1/c1);
m2 = mean(amp2/c2);
m3 = mean(amp3/c3);
m4 = mean(amp4/c4);

figure
plot(f,[amp1/c1 amp2/c2 amp3/c3 amp4/c4, m1*ones(size(amp1)) m2*ones(size(amp1)) m3*ones(size(amp1)) m4*ones(size(amp1)) ])
legend('1','2','3','4')

figure
plot(f,[amp1/c1 amp2/c2/m2*m1 amp3/c3/m3*m1 amp4/c4/m4*m1])
legend('1','2','3','4')

figure
plot(f,unwrap([Ph1 Ph2 Ph3 Ph4]))
legend('1','2','3','4')