function yci = simulateCI_clicktrain(y, Fs, fs_sig, F0, fmin, fmax, nchans, masker, ch_num)
% Simulate CI hearing using a vocoding procedure (Qin and Oxenham, 2003).
%
%
% USAGE:
%-------
% yci = simulateCI_clicktrain(y, Fs, F0, nchans)
%
% y: Input speech waveform (only left channel will be used if stereo)
% F0: Fundamental frequency of click train
% Fs: Sampling rate (Hz). Should be 44100 or more
% fs_sig: Sampling rate of original signal
% fmin, fmax: center frequencies for vocoding
% nchans: Number of channels
% masker: If sig is for masker, only one channel is extracted
% ch_num: Corresponding channel number for extraction, in the case of
% masker type
%--------
% Copyright 2016--2020 Hari Bharadwaj
% All Rights Reserved
%---------
% resample input signal to desired frequency 
y = resample(y, Fs, fs_sig);

% TO DO: ADD PRE-EMPHESIS FILTER
ncams = cams(fmax) - cams(fmin);
cams_per_chan = ncams / nchans;


f1_cams = cams(fmin) + cams_per_chan * (0: (nchans - 1)); %% left-edge frequency
f1 = invcams(f1_cams); %% Equally space CFs on an ERB scale
f2_cams = f1_cams + cams_per_chan; %% right-edge frequency
f2 = invcams(f2_cams); %% Equally space CFs on an ERB scale


f1 = f1 * 2.0 / Fs;  % Normalize to nyquist rate
f2 = f2 * 2.0 / Fs;

% Filter for envelope extraction
envcutoff = 70 * 2.0/Fs;
[benv, aenv] = butter(2, envcutoff); %2nd order BW

% Getting ready for windowing and sinusoid generation
yci = 0;
if masker == 1
    ch_nums = ch_num;
else
    ch_nums = 1: nchans;
end
for ch = ch_nums
    [b, a] = butter(3, [f1(ch), f2(ch)]);
    % filtfilt helps remove time delay of filtering, different filter bands
    % have different delays (eg. in the impulse response) hence phase compensation
    % could help align peaks from different filters
    yfilt = filtfilt(b, a, y(:, 1)); 
    
    if (f2(ch) - f1(ch))/2 < envcutoff
        tempcutoff = (f2(ch) - f1(ch)) / 2.0;
        [btemp, atemp] = butter(2, tempcutoff);
        yenv = filtfilt(btemp, atemp, yfilt.*(yfilt > 0));
    else
        yenv = filtfilt(benv, aenv, yfilt.*(yfilt > 0));
    end
    
    % click train carrier
    carr = zeros(size(yenv));
    harmonic = 1;
    ind = round(harmonic*Fs/F0);
    while ind <= numel(carr)
        carr(ind) = 1; % clcik of one
        harmonic = harmonic + 1;
        ind = round(harmonic*Fs/F0);
    end
    % Add noise to carrier to improve fricative and plosives without
    % affecting low-frequency TFS (so only add above 1500 Hz).
    if f1(ch) > 1200.0 * 2.0/Fs
        SNR = 20;
        factor  = db2mag(-1 * SNR);
        carr = carr + randn(size(yenv))*factor;
    end
    % one more filtering
    ych = filtfilt(b, a, carr.*yenv);
    ych = ych * sqrt(mean(yfilt.^2)) / sqrt(mean(ych.^2));
    yci = yci + ych;
end
    yci = rampsound(yci, Fs, 0.02);
end