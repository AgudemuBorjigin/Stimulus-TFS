demo = 0; % CHANGE THIS AS NEEDED
passive = 0; % CHANGE THIS AS NEEDED

% ITDlist = linspace(20e-6, 500e-6, 5); % ITD list
ITDlist = [20, 60, 180, 540]*1e-6;
trigList = 1:numel(ITDlist); % each trigger number is corresponding to one ITD in the list

% note that nperITD should be odd number 
if demo == 1
    nperITD = 4;
    nametag = '_demo';
elseif passive == 1
    nperITD = 300;
    nametag = '_passive';
else
    nperITD = 50;
    nametag = '';
end
nreps = numel(ITDlist)*nperITD; 
randITDs = zeros(1,nreps);
randTrigNums = zeros(1, nreps);
leftOrRight = zeros(1,nreps); % 1 means left ear, o means right ear
% randomizing the ITDs across all trials in each block presentation
temp = [];
for i = 1:numel(ITDlist)
    for j = 1:nperITD
        randITDs(j+(i-1)*nperITD) = ITDlist(i);
        randTrigNums(j+(i-1)*nperITD) = trigList(i);
        if j <= nperITD/2 % assuming nperITD is odd number
            leftOrRight(j+(i-1)*nperITD) =  1;
        else
            leftOrRight(j+(i-1)*nperITD) =  0;
        end
    end
end
randIndex = randperm(length(randITDs));
randITDs = randITDs(randIndex);
randTrigNums = randTrigNums(randIndex);
leftOrRight = leftOrRight(randIndex);
randITD_subset1 = randITDs(1:nreps/2);
randITD_subset2 = randITDs(nreps/2+1:nreps);
randTrigNums_subset1 = randTrigNums(1:nreps/2);
randTrigNums_subset2 = randTrigNums(nreps/2+1:nreps);
leftOrRight_subset1 = leftOrRight(1:nreps/2);
leftOrRight_subset2 = leftOrRight(nreps/2+1:nreps);
save(strcat('randITDsTrigNums', nametag, '.mat'),'randITDs','randTrigNums','ITDlist','trigList','leftOrRight', ...
    'randITD_subset1', 'randITD_subset2', 'randTrigNums_subset1', 'randTrigNums_subset2', 'leftOrRight_subset1', 'leftOrRight_subset2');