function [y, target, masker]  = stonemoore2014(x, onset, fs, SNR, rampdur, rmsset, playsound)

% RETURNS STEREO SIGNAL WITH RMS(L+R) = rmsset

if ~exist('playsound', 'var')
    playsound = 0;
end

if ~exist('rmsset', 'var')
    rmsset = 0.02;
end
%% Matching Stone & Moore 2014 processing strategy

nfilts = 28;
f_low = 1;
f_high = 8000;

% Equally space filter edges on an ERB scale
edges = invcams(linspace(cams(f_low), cams(f_high), nfilts+1));
cfs = edges(1:nfilts)*0.5 + edges(2:(nfilts+1))*0.5;

% Make all inputs as column vectors
x = x(:);


% Identify samples with speech energy (as opposed to pauses)
[b, a] = butter(4, 20/(fs/2));
e = filtfilt(b, a, abs(hilbert(x)));
thresh = 0.05;

%onset = ceil(numel(x)/2);
onset = ceil(onset*fs);
rmssamps = e > (max(abs(e))*thresh);
rmssamps = rmssamps(onset:end);
ntime = numel(x) - onset;
t = (0:(1/fs):((ntime - 1)/fs))';


% Extract BM responses (i.e., filter outputs)...
% Phase align the filters so that resynthesizing is trivial

fprintf(1, 'Extracting basilar membrane filter outputs!\n');
bm = gammatoneFast(x, cfs, fs, true);


% Resynthesize the sentence and synthesize the masker
y_odd = 0;
masker_odd = 0;
for k = 1:2:nfilts
    y_odd = y_odd + bm(:, k);
    tone = rms(bm(rmssamps, k)) * sin(2*pi*cfs(k)*t)*sqrt(2);
    tone = [zeros(onset, 1); rampsound(tone, fs, rampdur)];
    masker_odd = masker_odd + tone;
end

y_even = 0;
masker_even = 0;
for k = 2:2:nfilts
    y_even = y_even + bm(:, k);
    tone = rms(bm(rmssamps, k)) * sin(2*pi*cfs(k)*t)*sqrt(2);
    tone = [zeros(onset, 1); rampsound(tone, fs, rampdur)];
    masker_even = masker_even + tone;
end
factor = db2mag(-1*SNR);
y = [rampsound(y_odd + factor*masker_odd, fs, rampdur),...
    rampsound(y_even + masker_even*factor, fs, rampdur)];
targetrms = rms(sum(bm(rmssamps, :), 2));
y = y * rmsset/targetrms;
% for model
masker = masker_odd + masker_even;
target = y_odd + y_even;

%% Play sound
if playsound
    sound(y, fs);
end
end