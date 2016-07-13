function excelwritedecomp(filename,sheet,data)
%[freq, real(H21_1),imag(H21_1),real(H21_2),imag(H21_2), real(H11_21),imag(H11_21), R, T]
disp('Writing Data')

A=[sprintf('A2')];

titleA='A1';

titles = {'Frequency [Hz]', 'H21_1 Real', 'H21_1 Imag', 'H21_2 Real', 'H21_2 Imag', 'H11_21 Real', 'H11_21 Imag', 'R', 'T'};
xlswrite(filename,titles,sheet, titleA)

xlswrite(filename, data, sheet,A)

disp('Done Writing');
end