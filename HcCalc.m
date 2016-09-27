function HcCalc
%Calculates Hc based on the H12 and H21 data from two runs where the
%positions have been switched.

d = date;
filename1 = sprintf('Experimental Data/%s/M0P0R2', d);
filename2 = sprintf('Experimental Data/%s/M0P0R2', d);
sheet1 = 1;
sheet2 = 2;

mic_status = [1,2];

range=[1000:10:3000];
l = length(range);

alph = 'a':'z';

for x = mic_status(1):mic_status(end)
    pos = alph(11+(x-1)*10);
    H12 = xlsread(filename1, sheet1, sprintf('%s2:%s%i', pos, pos, l+1)) + i*xlsread(filename1, sheet1, sprintf('%s2:%s%i', pos+1, pos+1, l+1));
    H21 = xlsread(filename2, sheet2, sprintf('%s2:%s%i', pos, pos, l+1)) + i*xlsread(filename2, sheet2, sprintf('%s2:%s%i', pos+1, pos+1, l+1));

    format long g
    Hc = sqrt(H12.*H21);
    
    if x == 1
        r = spline(range', Hc);

        save('HcR', 'r')
        save([filename1 ' HcR'], 'r')
        title('HcR')
    elseif x == 2
        t = spline(range', Hc);

        save('HcT', 't')
        save([filename1 ' HcT'], 't')
        title('HcT')
    end
    
    plot(range, imag(Hc), '--', range, real(Hc), ':', range, abs(Hc))
    legend('Imaginary', 'Real', 'Absolute');
    hold on
end

end