function MibiComputerWriteLog(filename)
% function writes a log of the time every 5 minutes to a file

LogDir = ('/Users/lkeren/Box Sync/Leeat_Share/Data/');
nSecs= 250;

go = true;
while go
    pause(nSecs);
    c=clock;
    dlmwrite([LogDir,'/',filename],c,'-append')    
end