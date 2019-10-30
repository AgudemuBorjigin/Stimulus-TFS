demo = 0; % CHANGE THIS AS NEEDED
passive = 1; % CHANGE THIS AS NEEDED

% ITDlist = linspace(20e-6, 500e-6, 5); % ITD list
ITDlist = 180*1e-6;
trigList = 1:numel(ITDlist); % each trigger number is corresponding to one ITD in the list
if demo == 1
    nperITD = 3;
    nametag = '_demo';
elseif passive == 1
    nperITD = 600;
    nametag = '_passive';
else
    nperITD = 50;
    nametag = '';
end
nreps = numel(ITDlist)*nperITD; 
randITDs = zeros(1,nreps);
randTrigNums = zeros(1, nreps);
leftOrRight = cell(1,nreps);
% randomizing the ITDs across all trials in each block presentation
temp = [];
for i = 1:numel(ITDlist)
    for j = 1:nperITD
        randITDs(j+(i-1)*nperITD) = ITDlist(i);
        randTrigNums(j+(i-1)*nperITD) = trigList(i);
        if j <= nperITD/2
            leftOrRight{j+(i-1)*nperITD} =  'left';
        else
            leftOrRight{j+(i-1)*nperITD} =  'right';
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
save(strcat('randITDsTrigNums', nametag, '.mat'),'randITDs','randTrigNums','ITDlist','trigList','leftOrRight');