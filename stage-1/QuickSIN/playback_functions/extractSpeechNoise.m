function [out] = extractSpeechNoise(SNtype, sig, noiseCarrier, CF, fs)
% According to the speech+noise library, left channel is clean speech, while right channel is bubble background

if strcmp(SNtype,'intact')
    out = sum(sig);
else
    [Env_sum, Tfs_sum] = EnvTFS(sig,noiseCarrier, CF, fs);
    if strcmp(SNtype,'env')
        out = Env_sum;
    elseif strcmp(SNtype, 'tfs')
        out = Tfs_sum;
    end
end
end
