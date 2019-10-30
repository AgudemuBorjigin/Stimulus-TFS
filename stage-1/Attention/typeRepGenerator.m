% making sure different atten direction, stream type, pitch type has
% equal number of trials
demo = 1;

if demo == 1
    nBlocks = 1; % for formal test, it's 8
    nPerBlock = 8; % make sure it's divisible by 8, for formal test, it's 40, 320 trials in total
    fileNameTypeRep = 'typeDemo.mat';
else
    nBlocks = 8;
    nPerBlock = 40;
    fileNameTypeRep = 'type.mat';
end

type = [1 2 3 4 5 6 7 8]-1;
Types = [];
nRep = zeros(1, nBlocks*nPerBlock);
nRepNonTar = zeros(1, nBlocks*nPerBlock);

for i = 1:nBlocks
    for j = 1:nPerBlock/numel(type)
        Types = cat(2, Types, type);
    end
    for j = 1:nPerBlock
        nRep((i-1)*nPerBlock + j) = randi(4);
        nRepNonTar((i-1)*nPerBlock + j) = randi(4);
    end
end

Types = Types(randperm(numel(Types)));

save(fileNameTypeRep, 'Types', 'nBlocks', 'nPerBlock', 'nRep', 'nRepNonTar');

