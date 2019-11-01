fclist = 6000;

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
% prompt
subj = input('Please enter subject ID:', 's');
sID = strcat(subj);

load('startingDirection.mat');

nreps = 8;
nBlocks = nreps * numel(fclist);
for k = 1:numel(fclist)
    fc = fclist(k);
    for p = 1:nreps
        blockNum = (k-1)*numel(fclist) + p;
        
        [respList, ITDList, thresh] = getThreshILD3down1up(sID,fc, blockNum,...
            nBlocks, rightOrLeft{p}, useTDT,screenDist,screenWidth,buttonBox);
        fprintf(1, 'Threshold at %d Hz is %.1f us\n', fc, thresh*1e6);
    end
end


