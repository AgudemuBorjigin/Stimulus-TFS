% converged = 0;
% respList = [];
% ITDList = [];
% trialCount = 0;
% correctCount = 0;
% reps = 0; % used for 3 down 1 up

fileRoot = '/Users/Agudemu/Dropbox/Lab/Experiment/stimulus-TFS/stage-2/peripheral/ITD_behavior';
%%
ITD_start = 180e-6;
ITD_factor = 1.25;
ITD_max = ITD_start * (ITD_factor)^5;
ITD_min = ITD_start / (ITD_factor)^18;

ramp = 0.02; % AB: gating with 20-ms raised-cosine ramps
fc = 500;
fs = 100e3; % CHANGE AS NEEDED
dur = 0.4;
dur_gap = 0.2;
t = 0:1/fs:dur_gap-1/fs;
gap = zeros(2, numel(t));
%L = 70;

%%
ITDs = ITD_start * (ITD_factor).^(5:-1:-18);
steps = 10:-2:-36; % in dB
numParams = numel(ITDs);
fileNames_1 = cell(1, numParams);
fileNames_2 = cell(1, numParams);
count = 0;
for step = steps
    count = count + 1;
    % answer is one
    sig1 = makeITDstim_freqdomain(ITD_start * db2mag(step), 1, fc, fs,...
        dur, ramp);
    
    sig2 = makeITDstim_freqdomain(ITD_start * db2mag(step), 0, fc, fs,...
        dur, ramp);
    sig_one = [sig1'; gap'; sig2'];
    
    wavName_1 = strcat(num2str(step), 'dB_one.wav');
    fileNames_1{count} = wavName_1;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_1), sig_one/max(abs(sig_one(:))), fs);
    % answer is two
    sig1 = makeITDstim_freqdomain(ITD_start * db2mag(step), 1, fc, fs,...
        dur, ramp);
    
    sig2 = makeITDstim_freqdomain(ITD_start * db2mag(step), 0, fc, fs,...
        dur, ramp);
    sig_two = [sig1'; gap'; sig2'];
    
    wavName_2 = strcat(num2str(step), 'dB_two.wav');
    fileNames_2{count} = wavName_2;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_2), sig_two/max(abs(sig_two(:))), fs);
end

T_1 = cell2table(fileNames_1(:));
writetable(T_1, 'fileNames_1.csv');
T_2 = cell2table(fileNames_2(:));
writetable(T_2, 'fileNames_2.csv');