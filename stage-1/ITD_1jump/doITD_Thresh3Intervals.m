fclist = 500;
TFSorENV = 'TFS'; % Determines if the phase jump is in TFS or ENV

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
subj = input('Please enter subject ID:', 's');
nreps = 4;

load('target__3interval.mat');

sID = strcat(subj);
nBlocks = nreps * numel(fclist);
for k = 1:numel(fclist)
    fc = fclist(k);
    for p = 1:nreps
        blockNum = (k-1)*numel(fclist) + p;
        
        [respList, ITDList, thresh] = getThreshITD3Intervals(sID,fc, TFSorENV, blockNum,...
            nBlocks, target{p}, targetDir{p}, NmaxTrials, NminTrials, useTDT,screenDist,screenWidth,buttonBox);
        fprintf(1, 'Threshold at %d Hz is %f \n', fc, thresh);
    end
end

