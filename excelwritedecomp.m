function excelwritedecomp(filename,sheet,data, mic_status)
%[f S11 S12r S12i S22 PiPiC PrPrC PtPtC R T H12r H12i]
disp('Writing Data')

A=[sprintf('A2')];
M=[sprintf('M2')];

titleA='A1';

titles = {'Frequency [Hz]', 'S11 R [Pa^2]', 'S12r R [Pa^2]', 'S12i R [Pa^2]', 'S22 R [Pa^2]', 'PiPi* R [Pa^2]', 'PrPr* R [Pa^2]', 'PtPt* R [Pa^2]', 'R R', 'T R', 'H12r R', 'H12i R', 'S11_T', 'S12r_T', 'S12i_T', 'S22_T', 'PrPrC_T', 'PtPtC_T', 'R_T', 'T_T', 'H12r_T', 'H12i_T'};
xlswrite(filename,titles,sheet, titleA)

if mic_status == 1
    xlswrite(filename, data(:,1:12), sheet,A)
elseif mic_status == 2
    xlswrite(filename, data(:,13:22), sheet,M)
end

disp('Done Writing');
end