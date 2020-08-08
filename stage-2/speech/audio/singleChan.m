function stim = singleChan(stim, normval, SNR, t_mskonset, fs, rampdur, type)
stim = sigNorm(stim)*normval;
if strcmp(type, 'masker')
    stim = db2mag(-SNR)*stim;
    stim = rampsound(stim, fs, rampdur);
    stim = [zeros(int32(t_mskonset*fs), 1); stim];
end
end