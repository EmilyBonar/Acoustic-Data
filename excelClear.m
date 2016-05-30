function excelClear(filename, sheet)
xlswrite(filename,['0'],sheet)
[N, T, Raw]=xlsread(filename, sheet);
[Raw{:, :}]=deal(NaN);
xlswrite(filename, Raw, sheet);

end