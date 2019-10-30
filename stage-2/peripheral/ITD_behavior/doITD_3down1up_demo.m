fclist = 500;

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
subj = input('Please enter subject ID:', 's');
nreps = 1;

load('startingDirection_demo.mat');

sID = strcat(subj, '_3down1up_DEMO');
nBlocks = nreps * numel(fclist);
for k = 1:numel(fclist)
    fc = fclist(k);
    for p = 1:nreps
        blockNum = (k-1)*numel(fclist) + p;
        
        [respList, ITDList, thresh] = getThreshITD3down1up(sID,fc, blockNum,...
            nBlocks, rightOrLeft{p}, NmaxTrials, NminTrials, useTDT,screenDist,screenWidth,buttonBox);
        fprintf(1, 'Threshold at %d kHz is %f dB\n', fc, thresh);
    end
end

