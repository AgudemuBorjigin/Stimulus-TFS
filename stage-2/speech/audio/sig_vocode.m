function out = sig_vocode(audio_names, fs, f_low, f_high, fileRoot)
for i = 1:numel(audio_names)
    audioname = audio_names{i};
    [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
    sig = resample(sig, fs, fs_sig);
    sig_bands = bmresponse(sig, fs, numel(audio_names), f_low, f_high);
    single_band = sig_bands(:, i);
    %single_band = sigNorm(single_band); % this will equalize the energy in
    %each frequency band, leading to a more white-noise like spectrum, we
    %want, however, a more speech-like spectrum.
    if i == 1
        out = single_band;
    else
        [out, single_band] = zeroPadding(out, single_band);
        out = out + single_band;
    end   
end
out = sigNorm(out);
end