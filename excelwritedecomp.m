function excelwritedecomp(filename,sheet,data, mic_status)
%[f S11 S12r S12i S22 PiPiC PrPrC PtPtC R T H12r H12i]
disp('Writing Data')
if mic_status == 1
    A=[sprintf('A2')];

    titleA='A1';

    xlswrite(filename, data, sheet,A)
    
    titles = {'Frequency [Hz]', 'S11 [Pa^2]', 'S12r [Pa^2]', 'S12i [Pa^2]', 'S22 [Pa^2]', 'PiPi* [Pa^2]', 'PrPr* [Pa^2]', '', 'R', '', 'H12r', 'H12i'};
    xlswrite(filename,titles,sheet, titleA)
    
elseif mic_status == 2
    H=sprintf('H2');
    J=sprintf('J2');

    titleH='H1';
    titleJ='J1';
    PtPtC = data(:,8);
    T = data(:,10);
    xlswrite(filename,PtPtC,sheet,H)%write PtPt*
    xlswrite(filename,T,sheet,J)%write T

    xlswrite(filename,cellstr('PtPt* [Pa^2]'),sheet,titleH)
    xlswrite(filename,cellstr('T'),sheet,titleJ)
end

disp('Done Writing');
end