function stim = singleChan(stim, configuration, h, normval, SNR, t_mskonset, fs, type)
switch configuration
    case {'echo-pitch', 'echo', 'echo-space', 'echo-sum'}
        % leaving prompt part of the target free of reverberation
        if strcmp(type, 'target')
           stim_conv = sigNorm(conv(stim, h)); % normalization?
           stim_clean = sigNorm(stim); % normalization?
           [stim_clean, stim_conv] = zeroPadding(stim_clean, stim_conv);
           w_conv = ones(numel(stim_conv), 1);
           ramp = hanning(round(100e-3*fs)-1); % ~ 40 ms hanning window, -1 making the number of points even
           w_conv(int32(t_mskonset*fs - numel(ramp)/2):int32(t_mskonset*fs - 1)) = ramp(int32(1:numel(ramp)/2));
           w_conv(1:int32(t_mskonset*fs - numel(ramp)/2) - 1) = zeros(int32(t_mskonset*fs - numel(ramp)/2) - 1, 1);
           stim_conv = stim_conv.*w_conv;
           w_clean = 1 - w_conv;
           stim_clean = stim_clean.*w_clean; % normalization? 
           stim = stim_clean + stim_conv;
        else
           stim = conv(stim,h); 
        end
    otherwise
end
stim = sigNorm(stim)*normval;
if strcmp(type, 'masker')
    stim = db2mag(-SNR)*stim;
    stim = [zeros(int32(t_mskonset*fs), 1); stim];
end
end