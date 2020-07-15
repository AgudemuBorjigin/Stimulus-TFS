% converged = 0; % flag to determine when to stop getting threshold
% respList = [];
% ILDList = [];
% trialCount = 0;
% correctCount = 0;
% reps = 0;
fileRoot = '/Users/Agudemu/Dropbox/Lab/Experiment/stimulus-TFS/stage-2/peripheral/ILD';

fs = 200e3;
dur = 0.4;
dur_gap = 0.2;
ramp = 0.02;
fc = 6000;

t = 0:(1/fs):(dur - 1/fs);
t_gap = 0:(1/fs):(dur_gap - 1/fs);
sig = sin(2*pi*fc*t);
sig = int32(2^31 * rampsound(sig, fs, ramp));
gap = int32(zeros(2, numel(t_gap)));

L = 70; % reference level
ILD = 20; % starting ILD value in dB
ILDs = 30:-0.5:0;
fileNames_1 = cell(1, numel(ILDs));
fileNames_2 = cell(1, numel(ILDs));
count = 0;
for step = ILDs
    count = count + 1;
    ILD_left = [sig; sig * db2mag(-step)];
    ILD_right = [sig * db2mag(-step); sig];
    % answer is one (left)
    sig_one = [ILD_left'; gap'; ILD_right'];
    wavName_1 = strcat(num2str(step), 'dB_one.wav');
    fileNames_1{count} = wavName_1;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_1), sig_one, fs, 'BitsPerSample', 32);
    % answer is two
    sig_two = [ILD_right'; gap'; ILD_left'];
    wavName_2 = strcat(num2str(step), 'dB_two.wav');
    fileNames_2{count} = wavName_2;
    audiowrite(strcat(fileRoot, '/wavFiles/', wavName_2), sig_two, fs, 'BitsPerSample', 32);
end

T_1 = cell2table(fileNames_1(:));
writetable(T_1, 'fileNames_1.csv');
T_2 = cell2table(fileNames_2(:));
writetable(T_2, 'fileNames_2.csv');