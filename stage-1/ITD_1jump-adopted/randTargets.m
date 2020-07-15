% this is used to generate random targets among the intervals in adaptive
% measurements
demo = 0; % CHANGE AS NEEDED
interval = 3; % CHANGE AS NEEDED

if demo == 1
    nameTag = '_demo';
    nrep = 1; % CHNAGE AS NEEDED
else
    nameTag = '';
    nrep = 4; % CHANGE AS NEEDED
end
target = cell(1, nrep);
targetDir = cell(1, nrep);

if interval == 3
    NmaxTrials = 60;
    NminTrials = 30;
    targetTmp = zeros(1, NmaxTrials);
    targetTmp(NmaxTrials/3 + 1 : 2*NmaxTrials/3) = 1;
    targetTmp(2*NmaxTrials/3 +1 : end) = 2;
elseif interval  == 2
    NmaxTrials = 80;
    NminTrials = 20;
    targetTmp = zeros(1, NmaxTrials);
    targetTmp(NmaxTrials/2 + 1 : end) = 1;
end

targetDirTmp = zeros(1, NmaxTrials);
targetDirTmp(NmaxTrials/2 + 1 : end) = 1;

for i = 1: nrep
    randIndex = randperm(NmaxTrials);
    target{i} = targetTmp(randIndex);
    randIndex = randperm(NmaxTrials);
    targetDir{i} = targetDirTmp(randIndex);
end
save(strcat('target_', '_', num2str(interval), 'interval', nameTag, '.mat'), 'target', 'targetDir', 'NmaxTrials', 'NminTrials');
