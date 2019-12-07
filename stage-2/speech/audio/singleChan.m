function stim = singleChan(stim, configuration, h, normval, SNR, t_mskonset, fs, type)
switch configuration
    case {'echo-pitch', 'echo', 'echo-space', 'echo-sum'}
        stim = conv(stim,h);
    otherwise
end
stim = sigNorm(stim)*normval;
if strcmp(type, 'masker')
    stim = db2mag(-SNR)*stim;
    stim = [zeros(uint16(t_mskonset*fs), 1); stim];
end
end