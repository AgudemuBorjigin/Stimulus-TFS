% this is used to generate random targets among the intervals in adaptive
% measurements
demo = 0; % CHANGE AS NEEDED

if demo == 1
    nameTag = '_demo';
    nrep = 1; % CHNAGE AS NEEDED
else
    nameTag = '';
    nrep = 8; % CHANGE AS NEEDED
end

NmaxTrials = 1000;
NminTrials = 20;
rightOrLeft = cell(1, nrep);
dirTmp = zeros(1, NmaxTrials);
dirTmp((NmaxTrials/2 +1) : end) = 1;

for i = 1: nrep
    randIndex = randperm(NmaxTrials);
    rightOrLeft{i} = dirTmp(randIndex);
end
save(strcat('startingDirection', nameTag, '.mat'), 'rightOrLeft', 'NmaxTrials', 'NminTrials');
