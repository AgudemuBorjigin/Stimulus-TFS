% converged = 0; % flag to determine when to stop getting threshold
% respList = [];
% fdevList = [];
% trialCount = 0;
% correctCount = 0;

% Nup = 3; % Weighted 1-up-1down with weights of 3:1
% fdev_step_down = db2mag(-4)
% fdev_step_up = db2mag(-fdev_step_down) * Nup
% NmaxTrials = 80;
% NminTrials = 20;
% target = (randperm(NmaxTrials) > NmaxTrials/2); % randomizing target (containing FM)
fileRoot = '/Users/Agudemu/Dropbox/Lab/Experiment/stimulus-TFS/stage-2/peripheral/binauralFM';
%%
fdev_step = 1; 
fdev_start = 16;
fdev_max = 20;
fdev_min = 0;
ramp = 0.025; % gating with 25-ms raised-cosine ramps
fc = 500;
fm = 2;
fs = 48828;
dur = 0.5;
% L = 70;
t = 0:1/fs:dur-1/fs;
gap = zeros(2, numel(t));

fdevs = fdev_min:fdev_step:fdev_max;
steps = 2:-2:-24;
numParams = numel(steps);
if rem(numParams, 2) == 0
    dev_dir = [ones(1, numParams/2), -1*ones(1, numParams/2)];
else
    dev_dir = [ones(1, (numParams+1)/2), -1*ones(1, (numParams-1)/2)];
end
dev_dir = dev_dir(randperm(numParams)); % randomizing target (containing FM)
%%
fileNames_1 = cell(1, numParams);
fileNames_2 = cell(1, numParams);
count = 0;
for step = steps
    count = count + 1;
    dir = dev_dir(count);
    sig_left = makeFMstim_binaural(dir, fdev_start * db2mag(step), fc, fs, fm,...
        dur, ramp);
    sig_right = makeFMstim_binaural(-1 * dir, fdev_start * db2mag(step), fc, fs, fm,...
        dur, ramp);
    sig_tar = [sig_left; sig_right];
    sig_pure = makeFMstim_binaural(dir, 0, fc, fs, fm, dur, ramp);
    sig_ref = [sig_pure; sig_pure];
    % target = 1 : left button
    tar_1 = [sig_tar'; gap'; sig_ref'];
    wavName_1 = strcat(num2str(step), 'dB_one.wav');
    fileNames_1{count} = wavName_1;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_1), tar_1/max(abs(tar_1(:))), fs);
    % target = 2 : right button
    tar_2 = [sig_ref'; gap'; sig_tar'];
    wavName_2 = strcat(num2str(step), 'dB_two.wav');
    fileNames_2{count} = wavName_2;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_2), tar_2/max(abs(tar_2(:))), fs);
end

T_1 = cell2table(fileNames_1(:));
writetable(T_1, 'fileNames_1.csv');
T_2 = cell2table(fileNames_2(:));
writetable(T_2, 'fileNames_2.csv');

