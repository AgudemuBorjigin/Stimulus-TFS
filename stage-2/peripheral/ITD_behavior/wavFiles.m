fileRoot = pwd;
%% stimulus parameters
ramp = 0.02; % AB: gating with 20-ms raised-cosine ramps
fc = 500;
fs = 100e3; % CHANGE AS NEEDED
dur = 0.5;
dur_gap = 0.5;
t = 0:1/fs:dur_gap-1/fs;
gap = zeros(2, numel(t));

% NOTE: ITD here is only for one of two stimulus segments in the "jumpting" stimulus 
ITD_start =128;
ITD_factor = 2;
ITDs = round(ITD_start * (ITD_factor).^(0:-1:-6));
% steps = ITD_start;
% numReps = 15;
steps = ITDs; 
numReps = 8;
numSteps = numReps*numel(steps);
stepsAll = zeros(1, numSteps);
for i = 1:numReps
    stepsAll((i-1)*numel(steps)+(1:numel(steps))) = steps;
end
stepsAll = stepsAll(randperm(numSteps));
%%
symbols = ['a':'z' 'A':'Z' '0':'9'];
fileNames = cell(1, numSteps);
count = 0;
for step = stepsAll
    count = count + 1;
    answer = randi(2);
    if answer == 1
        lr_sig1 = 1;
        lr_sig2 = 0;
    else
        lr_sig1 = 0;
        lr_sig2 = 1;
    end
    sig1 = makeITDstim_freqdomain(step*1e-6, lr_sig1, fc, fs,...
        dur, ramp);
    
    sig2 = makeITDstim_freqdomain(step*1e-6, lr_sig2, fc, fs,...
        dur, ramp);   
    sig = [sig1'; gap'; sig2'];
    
    idx = randi(numel(symbols), [1, 16]);
    hashString = symbols(idx);
    wavName = strcat(num2str(step), 'us_', num2str(answer), '_', hashString, '.wav');
    fileNames{count} = wavName;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName), sig/max(abs(sig(:))), fs);
    if count == 1
        sig_no_ITD = makeITDstim_freqdomain(0, 0, fc, fs,...
            dur, ramp);
        sig_no_ITD = [sig_no_ITD'; gap'];
        for i = 1:100
            if i == 1
                volume = sig_no_ITD;
            else
                volume = [volume; sig_no_ITD]; %#ok<AGROW>
            end
        end
        audiowrite(strcat(fileRoot, '/wavFiles/', 'volume.wav'), volume/max(abs(volume(:))), fs);
    end
end

T = cell2table(fileNames(:));
writetable(T, strcat(fileRoot, '/wavFiles/', 'fileNames.csv'));