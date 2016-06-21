clear all
clc

d = date;

for mic_status = 1:2
    for sheet = 1:3
         t = '';
        if mic_status == 2
            t = 'T';
        end
        
        filename=sprintf('Experimental Data/%s/M1P0B1R%i%s-1', d, sheet+3, t); %must change to file that you want to load from
        filename_excel =sprintf('Experimental Data/%s/M1P0B1.xlsx', d); %must change to file that you want to load from
        mainAnalysis(filename, filename_excel, sheet, mic_status)
     end
end