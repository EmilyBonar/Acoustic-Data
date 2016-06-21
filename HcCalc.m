function HcCalc
%Calculates Hc based on the H12 and H21 data from two runs where the
%positions have been switched.

d = date;
filename1 = sprintf('Experimental Data/%s/M1P0B2R1', d);
filename2 = sprintf('Experimental Data/%s/M1P0B2R1', d);
sheet1 = 1;
sheet2 = 2;

range=[1800:25:1900,1910:20:1970,1975:5:2000,2001:1:2039, 2040:5:2055, 2060:20:2140, 2150:25:2250];
l = length(range);

H12 = xlsread(filename1, sheet1, sprintf('K2:K%i',l+1)) + i*xlsread(filename1, sheet1, sprintf('L2:L%i',l+1));
H21 = xlsread(filename2, sheet2, sprintf('K2:K%i',l+1)) + i*xlsread(filename2, sheet2, sprintf('L2:L%i',l+1));

format long g
Hc = sqrt(H12.*H21);

s = spline(range', Hc);

save('Hc', 's')
save([filename1 ' Hc'], 's')

plot(range, imag(Hc), '--', range, real(Hc), ':', range, abs(Hc))

legend('Imaginary', 'Real', 'Absolute');
end

