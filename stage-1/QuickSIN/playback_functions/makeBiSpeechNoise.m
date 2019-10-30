function [out] = makeBiSpeechNoise(listNum, SNR, SNtype, location, b, fs)
filePath = '/home/agudemu/Experiment/Stimulus/QuickSIN/original_stimuli_harvard/'; % CHANGE AS NEEDED
fileName = strcat(filePath,'list',num2str(listNum),'_snr',num2str(SNR),'.mat');
load(fileName, 'sig');

arrayLength = 26.4;% length of electrode array (active stimulation range), FLEXSOFT from MEDEL
eletdNum = 12;% number of electrodes, FLEXSOFT from MEDEL

sig = sig'; %#ok<NODEF> % sig is from the output of loaded data
% The signal and background should be normalized by their RMS
% (only the speech portion, excluding the silent period was used to calculate RMS)
speech = sig(1,:);
speech = sigNorm(speech);

background = sig(2,:);
background = filter(b, 1, background); % this operation could avoid taking ifft which leads to complex numbers
background = sigNorm(background);
%     this section of code introduces noise, because it's individual not
%     grand average
%     backgroundF = fft(background);
%     speechF = fft(speech);
%     gainF = abs(speechF)./abs(backgroundF);
%     backgroundF_norm = backgroundF.*gainF;
%     application of lpc (linear prediction filter)
%     a = lpc(gainF_avg);
%     gainF_avg = filter([0 -a(2:end)],1,gainF_avg);
%     backgroundF_norm = backgroundF.*gainF_avg;
%     background = ifft(backgroundF_norm);

if strcmp(location,'colocated')
    singleChann = db2mag(-SNR)*background+speech;
    
    % recaling in case the signal amplitude is greater than 1, to avoid
    % clipping
    if max(abs(singleChann))>1
        singleChann = singleChann/max(abs(singleChann));
    end
    if strcmp(SNtype, 'intact')
        out_left = singleChann;
        out_right = singleChann;
    elseif strcmp(SNtype, 'CIshiftSymtc')
        insertDepth = 34; % trying to provide useful TFS not the ones in the case of hearing impairment
        singleChann = insertDepthSimCI(singleChann, fs, insertDepth, arrayLength, eletdNum);
        out_left = singleChann;
        out_right = singleChann;
    elseif strcmp(SNtype, 'CIshiftNonSymtc')
        insertDepth = 34;
        singleChann = insertDepthSimCI(singleChann, fs, insertDepth, arrayLength, eletdNum);
        out_left = singleChann;
        insertDepth = 30;
        singleChann = insertDepthSimCI(singleChann, fs, insertDepth, arrayLength, eletdNum);
        out_right = singleChann;
    end
    
    % binaural stimulus
    out = [out_left;out_right];
    
    % CHANGE THE ADDRESS AS NEEDED
    save(strcat('/home/agudemu/Experiment/Stimulus/QuickSIN/soundmatsHarvard/colocated/',SNtype,'/','List',num2str(listNum),'_',num2str(SNR),'.mat'),'out');
    
elseif strcmp(location,'separated')
    % in separated condition (easier), each SNR step was reduced by 3
    rightEar = db2mag(-(SNR-3))*background+speech; 
    if max(abs(rightEar))>1
        rightEar = rightEar/max(abs(rightEar));
    end
    % phase inversion: BMLD
    background = -1*sig(2,:);
    background = filter(b, 1, background);
    background = sigNorm(background);
    % in separated condition (easier), each SNR step was reduced by 3
    leftEar = db2mag(-(SNR-3))*background+speech; 
    if max(abs(leftEar))>1
        leftEar = leftEar/max(abs(leftEar));
    end
    
    if strcmp(SNtype, 'CIshiftSymtc')
        insertDepth = 34;
        leftEar = insertDepthSimCI(leftEar, fs, insertDepth, arrayLength, eletdNum);
        rightEar = insertDepthSimCI(rightEar, fs, insertDepth, arrayLength, eletdNum);
    elseif strcmp(SNtype, 'CIshiftNonSymtc')
        insertDepth = 34;
        leftEar = insertDepthSimCI(leftEar, fs, insertDepth, arrayLength, eletdNum);
        insertDepth = 30;
        rightEar = insertDepthSimCI(rightEar, fs, insertDepth, arrayLength, eletdNum);
    end
    
    out = [leftEar;rightEar];
    % CHANGE THE ADDRESS AS NEEDED
    save(strcat('/home/agudemu/Experiment/Stimulus/QuickSIN/soundmatsHarvard/separated/',SNtype,'/','List',num2str(listNum),'_',num2str(SNR-3),'.mat'),'out');
end
end