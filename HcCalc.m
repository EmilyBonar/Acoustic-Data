function HcCalc
%Calculates Hc based on the H12 and H21 data from two runs where the
%positions have been switched.

d = date;
filename1 = sprintf('Experimental Data/%s/metal fork first hole with blue mount2 closeup rez half Hz', d);
filename2 = sprintf('Experimental Data/%s/metal fork first hole with blue mount2 closeup rez half Hz', d);
sheet1 = 1;
sheet2 = 2;

range =(2010:.5:2040);
l = length(range);

H12 = xlsread(filename1, sheet1, sprintf('K2:K%i',l+1)) + i*xlsread(filename1, sheet1, sprintf('L2:L%i',l+1));
H21 = xlsread(filename2, sheet2, sprintf('K2:K%i',l+1)) + i*xlsread(filename2, sheet2, sprintf('L2:L%i',l+1));

format long g
Hc = sqrt(H12.*H21);

s = spline(range', Hc);
save('Hc', 's')

plot(range, imag(Hc), '--', range, real(Hc), ':', range, abs(Hc))
legend('Imaginary', 'Real', 'Absolute');
end

