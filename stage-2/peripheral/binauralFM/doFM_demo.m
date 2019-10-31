fclist = 500;

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
subj = input('Please enter subject ID:', 's');
earflag = 1;
nreps = 1;

sID = strcat(subj, '_DEMO');
nBlocks = nreps * numel(fclist);
for k = 1:numel(fclist)
    fc = fclist(k);
    for p = 1:nreps
        blockNum = (k-1)*numel(fclist) + p;
        
        [respList, fdevList, thresh] = getThreshFM(sID,fc, blockNum,...
            nBlocks,useTDT,screenDist,screenWidth,buttonBox);
        fprintf(1, 'Threshold at %d kHz is %f dB\n', fc, thresh);
    end
    
end

