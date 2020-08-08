function [out, out_intact] = sig_vocode(audio_names, fs, f_low, f_high, fileRoot, gender, masker, Nchans)
if masker == 1
    if gender == 'M'
        pitch_freq = 80;
    else
        pitch_freq = 240;
    end
    if numel(audio_names) > 1
        for i = 1: Nchans
            audioname = audio_names{i};
            [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
            single_band = simulateCI_clicktrain(sig, fs, fs_sig, pitch_freq, f_low, f_high, Nchans, masker, i);
            if i == 1
                out = single_band;
            else
                [out, single_band] = zeroPadding(out, single_band);
                out = out + single_band;
            end
        end
        out_intact = ones(size(out, [1, 2]));
    else
        audioname = audio_names{1};
        [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
        out_intact = resample(sig, fs, fs_sig);
        out = ones(size(out_intact, [1, 2]));
    end
else % for the target
    if gender == 'M'
        pitch_freq = 90;
    else
        pitch_freq = 250;
    end
    [sig, fs_sig] = audioread(audio_names);
    out_intact = resample(sig, fs, fs_sig);
    out = simulateCI_clicktrain(sig, fs, fs_sig, pitch_freq, f_low, f_high, Nchans, masker, []);
end
out = sigNorm(out);
out_intact = sigNorm(out_intact);
end