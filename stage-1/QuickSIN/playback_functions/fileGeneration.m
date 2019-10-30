% NOTE: the SNR steps for the makeBiSpeechNoise function is hardcoded
% CHANGE AS NEEDED
nlist = 10;
nSNR = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% colocated, intact: list 1-10, separated, intact: list 11-20, 

% colocated, CIShiftSymtc: list 21-30, colocated, CIShiftNonSymtc: list
%31-40
% separated, CIShiftSymtc: list 41-50, separated, CIShiftNonSymtc: list
% 51-60
SNtype = 'CIshiftSymtc'; % 'intact', 'CIshiftSymtc', 'CIshiftNonSymtc'
listNumOffset = 20; %CHANGE AS NEEDED
location = 'colocated'; % 'colocated' or 'separated'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SNRrange = 12:-3:-3;

% CHNAGE AS NEEDED
filePath = '/home/agudemu/Experiment/Stimulus/QuickSIN/original_stimuli_harvard/';

gainFs = cell(1, nlist*nSNR);

% collection of frequency magnitude response from all targets and
% backgrounds
abs_speech = cell(1, nlist*nSNR);
abs_background = cell(1, nlist*nSNR);
k = 0;
for listNum = 1:nlist
    for SNR = SNRrange 
        k = k+1;
        fileName = strcat(filePath,'list',num2str(listNum+listNumOffset),'_snr',num2str(SNR),'.mat');
        load(fileName);
        sig = sig';
        speech = sig(1,:);
        background = sig(2,:);
        speechFft = fft(speech);
        backgroundFft = fft(background);
        abs_speech{(listNum-1)*nSNR + k} = abs(speechFft); 
        abs_background{(listNum-1)*nSNR + k} = abs(backgroundFft); 
    end
    k = 0;
end

% average of fft of all targets and backgrounds
speech_avg = zeros(1, length(abs_speech{1}));
for k = 1:nlist*nSNR
    speech_avg = speech_avg + abs_speech{k};
end
speech_avg = speech_avg/(nlist*nSNR);

bckg_avg = zeros(1, length(abs_background{1}));
for k = 1:nlist*nSNR
    bckg_avg = bckg_avg + abs_background{k};
end
bckg_avg = bckg_avg/(nlist*nSNR);
% gain/ratio between target and background
gainF_avg = speech_avg./bckg_avg;

% % low pass filtering
% fc = 50; fs = 44100;
% [b, a] = butter(1, fc/(fs/2));
% gainF_avg = filter(b, a, gainF_avg);

% generation of fitler parameter according to the gain 
f = (0:(numel(gainF_avg) - 1))*fs/numel(gainF_avg);
f_half = f(f< fs/2);
gain_half = gainF_avg(f<fs/2);
b = fir2(128, f_half/max(f_half), gain_half); % smaller the filter order, smoother the filter
% fvtool(b,1)

for listNum = 1:nlist
    % storing the reference for the listener
    for i = 1:2 % CHANGE AS NEEDED, two references in this case
        fileName = strcat(filePath,'list',num2str(listNum+listNumOffset),'_reference', int2str(i), '.mat');
        load(fileName);
        out = sig';
        speech = out(1,:);
        speech = sigNorm(speech);
        
        if max(abs(speech))>1
            speech = speech/max(abs(speech));
        end
        
        out = [speech; speech];
        if strcmp(location, 'colocated')
            save(strcat('/home/agudemu/Experiment/Stimulus/QuickSIN/soundmatsHarvard/colocated/',SNtype,'/','List',num2str(listNum+listNumOffset),'_reference', int2str(i), '.mat'),'out');
        else
            save(strcat('/home/agudemu/Experiment/Stimulus/QuickSIN/soundmatsHarvard/separated/',SNtype,'/','List',num2str(listNum+listNumOffset),'_reference', int2str(i), '.mat'),'out');
        end
    end
    for SNR = SNRrange
        makeBiSpeechNoise(listNum + listNumOffset,SNR, SNtype,location, b, fs); 
    end
end
