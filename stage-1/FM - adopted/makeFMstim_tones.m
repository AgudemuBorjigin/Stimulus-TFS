function [FM, t] = makeFMstim_tones(fdev, fc, fs, fm, dur, ramp)

% USAGE:
%   [FM] = makeFMstim_tones(m, fc, fs, fm, fdev, fmlow, fmhi, TFR, flankdist, dur, ramp)
% INPUTS:
%   m: Amplitude
%   fc: Center frequency of target (Hz)
%   bw: Target bandwidth (ERB) AB: may not be necessary
%   fs: Sampling rate (Hz)
%   fm: Target modulation frequency (Hz)
%   fdev: Target frequency deviation
%   fmlo: Low-side flanker modulation frequency (Hz) AB
%   fmhi: High-side modulation frequency (Hz) AB
%   TFR: Target to flanker ratio AB
%   flankdist: How far are flankers away from target (in ERB units) AB
%   dur: Duration of stimulus (s)
%   ramp: Duration of ramp on either end (s)
%
% OUTPUTS:
%   FM: Generated stimulus (1 x samples)
%
%--------------------------------------
% Copyright Agudemu Borjigan. All Rights Reserved
%--------------------------------------

t = 0:(1/fs):(dur - 1/fs);


phi = 1.5*pi; % fm phase is set to 1.5 pi

FM = sin(2*pi*fc*t+(fdev/fm)*sin(2*pi*fm*t+phi));
% FM = sin(2*pi*(fc+sin(2*pi*fm*t+phi)).*t);
% figure,plot(t, FM, 'b');
% hold on;
% plot(t, sin(2*pi*fm*t+phi), 'r');

FM = rampsound(FM, fs, ramp);
FM = FM/rms(FM); %AB
FM = scaleSound(FM);
end