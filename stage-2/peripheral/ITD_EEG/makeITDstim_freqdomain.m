function out = makeITDstim_freqdomain(ITD, rightOrLeft, fc, fs, dur)
%--------------------------------------
% Copyright Agudemu Borjigan. All Rights Reserved
% ITD should be in u seconds
% rightOrLeft = 1 means left ear leading
%--------------------------------------

t = 0:(1/fs):(dur - 1/fs);
Nsamps = numel(t);

f = (0:(Nsamps-1))*fs/Nsamps;

[~, tone_index] = min(abs(f - fc));
fprintf(1, 'Note that the exact tone frequency is %f Hz\n', f(tone_index));

Xf = zeros(size(f));
Xf(tone_index) = 1;
Xf(Nsamps - tone_index + 1) = 1;

Xphase = exp(-2j*pi*ITD*f);

sig_lead = ifft(Xf, 'symmetric');
sig_lag = ifft(Xf.*Xphase, 'symmetric');

if rightOrLeft
    sig(1, :) = sig_lead;
    sig(2, :) = sig_lag;
else
    sig(2, :) = sig_lead;
    sig(1, :) = sig_lag;
end
out = sig;

