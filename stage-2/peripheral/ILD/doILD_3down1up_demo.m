fclist = 6000;

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
% prompt
subj = input('Please enter subject ID:', 's');
sID = strcat(subj, '_DEMO');

load('startingDirection_demo.mat');

nreps = 1;
nBlocks = nreps * numel(fclist);
for k = 1:numel(fclist)
    fc = fclist(k);
    for p = 1:nreps
        blockNum = (k-1)*numel(fclist) + p;
        
        [respList, ITDList, thresh] = getThreshILD3down1up(sID,fc, blockNum,...
            nBlocks, rightOrLeft{p}, useTDT,screenDist,screenWidth,buttonBox);
        fprintf(1, 'Threshold at %d kHz is %f dB\n', fc, thresh);
    end
end

