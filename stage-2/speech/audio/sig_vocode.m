function [out, out_intact] = sig_vocode(audio_names, fs, f_low, f_high, fileRoot, masker, Nchans, vocode, unintelligible, pitch_freq)
if masker == 1
    if vocode
        if unintelligible
            for i = 1: Nchans
                audioname = audio_names{i};
                [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
                single_band = simulateCI_clicktrain(sig, fs, fs_sig, pitch_freq, f_low, f_high, Nchans, masker, i, unintelligible);
                if i == 1
                    out = single_band;
                else
                    [out, single_band] = zeroPadding(out, single_band);
                    out = out + single_band;
                end
            end
        else
            audioname = audio_names{1};
            [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
            out = simulateCI_clicktrain(sig, fs_sig, pitch_freq, f_low, f_high, Nchans, masker, [], unintelligible);
        end
        out_intact = ones(size(out, [1, 2]));
    else
        audioname = audio_names{1};
        [sig, fs_sig] = audioread(strcat(fileRoot, '/harvard_sentences/', audioname(1:6), '/audio/', audioname));
        out_intact = resample(sig, fs, fs_sig);
        out = ones(size(out_intact, [1, 2]));
    end
else % for the target
    [sig, fs_sig] = audioread(audio_names);
    out_intact = resample(sig, fs, fs_sig);
    out = simulateCI_clicktrain(sig, fs_sig, pitch_freq, f_low, f_high, Nchans, masker, [], unintelligible);
end
out = sigNorm(out);
out_intact = sigNorm(out_intact);
end