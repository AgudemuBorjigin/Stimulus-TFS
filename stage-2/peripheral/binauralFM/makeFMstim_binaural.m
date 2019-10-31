function [FM, t] = makeFMstim_binaural(dev_dir, fdev, fc, fs, fm, dur, ramp)

% USAGE:
%   [FM] = makeFMstim_tones(m, fc, fs, fm, fdev, fmlow, fmhi, TFR, flankdist, dur, ramp)
% INPUTS:
%   fc: Center frequency of target (Hz)
%   fs: Sampling rate (Hz)
%   fm: Target modulation frequency (Hz)
%   fdev: Target frequency deviation
%   dur: Duration of stimulus (s)
%   ramp: Duration of ramp on either end (s)
%
% OUTPUTS:
%   FM: Generated stimulus (1 x samples)
%
%--------------------------------------
% Copyright Agudemu Borjigin. All Rights Reserved
%--------------------------------------

t = 0:(1/fs):(dur - 1/fs);


phi = 0; % AB edited (Strelcyk had 1.5*pi)

FM = sin(2*pi*fc*t+(dev_dir*fdev/fm)*sin(2*pi*fm*t+phi));

FM = rampsound(FM, fs, ramp);
FM = FM/rms(FM); 
FM = scaleSound(FM);
end