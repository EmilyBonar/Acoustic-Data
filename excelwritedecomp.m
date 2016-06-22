function excelwritedecomp(filename,sheet,data)
%[f S11 S12 S21 S22 PiPiC PrPrC PtPtC R T H12r H12i]
disp('Writing Data')
A=[sprintf('A2')];

titleA='A1';

xlswrite(filename, data, sheet,A)

titles = {'Frequency [Hz]', 'S11 [Pa^2]', 'S12 [Pa^2]', 'S21 [Pa^2]', 'S22 [Pa^2]', 'PiPi* [Pa^2]', 'PrPr* [Pa^2]', 'PtPt* [Pa^2]', 'R', 'T', 'H12r', 'H12i'};
xlswrite(filename,titles,sheet, titleA)


disp('Done Writing');
end