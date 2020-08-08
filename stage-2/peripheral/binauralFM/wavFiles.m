fileRoot = pwd;
%%
ramp = 0.02; % gating with 25-ms raised-cosine ramps
fc = 500;
fm = 2;
fs = 48828;
dur = 0.5;
t = 0:1/fs:dur-1/fs;
gap = zeros(2, numel(t));
 
fdev_max = 3.2;
FM_factor = 2;
% steps = fdev_max * FM_factor.^(0:-1:-5);
% numReps = 8;
steps = fdev_max;
numReps = 15;
numSteps = numReps*numel(steps);
stepsAll = zeros(1, numSteps);
for i = 1:numReps
    stepsAll((i-1)*numel(steps)+(1:numel(steps))) = steps;
end
stepsAll = stepsAll(randperm(numSteps));
%%
fileNames = cell(1, numSteps);
count = 0;
symbols = ['a':'z' 'A':'Z' '0':'9'];
for step = stepsAll
    count = count + 1;
    dirs = [-1, 1];
    dir = dirs(randi(2));
    answer = randi(2);
    % target
    sig_left = makeFMstim_binaural(dir, step, fc, fs, fm,...
        dur, ramp);
    sig_right = makeFMstim_binaural(-1 * dir, step, fc, fs, fm,...
        dur, ramp);
    sig_tar = [sig_left; sig_right];
    % control
    sig_pure = makeFMstim_binaural(dir, 0, fc, fs, fm, dur, ramp);
    sig_ref = [sig_pure; sig_pure];
    if answer == 1
        % target = 1 : left button
        tar = [sig_tar'; gap'; sig_ref'];
    else
        % target = 2 : right button
        tar = [sig_ref'; gap'; sig_tar'];
    end
    idx = randi(numel(symbols), [1, 16]);
    hashString = symbols(idx);
    wavName = strcat(num2str(step), 'Hz_', num2str(answer), '_', hashString, '.wav');
    fileNames{count} = wavName;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName), tar/max(abs(tar(:))), fs);
    if count == 1
        sig_no_FM = [sig_ref'; gap'];
        for i = 1:100
            if i == 1
                volume = sig_no_FM;
            else
                volume = [volume; sig_no_FM]; %#ok<AGROW>
            end
        end
        audiowrite(strcat(fileRoot, '/wavFiles/', 'volume.wav'), volume/max(abs(volume(:))), fs);
    end
end
T = cell2table(fileNames(:));
writetable(T, strcat(fileRoot, '/wavFiles/', 'fileNames.csv'));

