function [out, dur_total] = stim_forwardMask(dur, fc, fs, ramp)
t = 0:1/fs:dur-1/fs;
probe = rampsound(sin(2*pi*fc*t), fs, ramp);
probe = probe/rms(probe); % normalization 

% % band_limited "white" noise
% % filter parameters for filtering white noise, ERB: Glasberg and Moore 1990
% %ERB = fc/5; % simpler version of the ERB calculation
% ERB = 24.7*(4.37*fc/1000+1);
% fLow = fc - ERB/2;
% fHigh = fc + ERB/2;
% fn = fs/2;
% [b, a] = butter(2,[fLow/fn fHigh/fn]); % 2nd order butterworth filtering
% % filtered white noise as masker
% masker = randn(1, numel(t));
% masker = rampsound(filtfilt(b, a, masker), fs, ramp);
% masker = masker*db2mag(10)/rms(masker); % noise is 10 db louder than probe

masker = db2mag(10)*probe;

gap1 = zeros(1, round(50e-3*fs));
gap2 = zeros(1, round(1e-3*fs));

out = [probe gap1 masker gap2 probe gap1 gap1 gap1 gap1];
out = scaleSound(out);
dur_total = length(out)/fs;
end
