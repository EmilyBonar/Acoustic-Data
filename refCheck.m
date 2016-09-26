function refCheck

rc = [0.16:0.02:0.24];
rshift = [0:5:355];

for x = 1:length(rc)
    for y = 1:length(rshift)
        filename = sprintf('Reflection Testing/A:%e Ph:%i',rc(x),rshift(y));

        IdealGen(filename,rc,rshift);
        IdealAnalysis(filename,filename,1);
        createfigure({filename},'Reflection Testing/Graphs');
        
        delete([filename '.mat']);
        clear all
    end
end

end