fileRoot = pwd;

fs = 48828;
fc = 4000;

dur = 0.5;
dur_gap = 0.5;
t = 0:(1/fs):(dur - 1/fs);

ramp = 0.02;
sig = sin(2*pi*fc*t);
sig = rampsound(sig, fs, ramp);
gap = zeros(2, numel(t));

factor = 2;
ILD_max = 3.2;
ILDs = ILD_max * (factor.^(0:-1:-5));
% steps = ILDs;
% numReps = 8;
steps = ILD_max;
numReps = 15;
numParams = numel(steps);
numSteps = numReps*numParams;
stepsAll = zeros(1, numSteps);
for i = 1:numReps
    stepsAll((i-1)*numel(steps)+(1:numel(steps))) = steps;
end
stepsAll = stepsAll(randperm(numSteps));
fileNames = cell(1, numSteps);
count = 0;
symbols = ['a':'z' 'A':'Z' '0':'9'];
for step = stepsAll
    count = count + 1;
    answer = randi(2);
    ILD_left = [sig; sig * db2mag(-step)];
    ILD_right = [sig * db2mag(-step); sig];
    if answer == 1
        % answer is one (left)
        sig_mix = [ILD_left'; gap'; ILD_right'];
    else
        % answer is two
        sig_mix = [ILD_right'; gap'; ILD_left'];
    end 
    idx = randi(numel(symbols), [1, 16]);
    hashString = symbols(idx);
    wavName = strcat(num2str(step), 'dB_', num2str(answer), '_', hashString, '.wav');
    fileNames{count} = wavName;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName), sig_mix/max(abs(sig_mix(:))), fs);
    if count == 1
        sig_no_ILD = [[sig; sig]'; gap'];
        for i = 1:100
            if i == 1
                volume = sig_no_ILD;
            else
                volume = [volume; sig_no_ILD]; %#ok<AGROW>
            end
        end
        audiowrite(strcat(fileRoot, '/wavFiles/', 'volume.wav'), volume/max(abs(volume(:))), fs);
    end
end

T = cell2table(fileNames(:));
writetable(T, strcat(fileRoot, '/wavFiles/', 'fileNames.csv'));