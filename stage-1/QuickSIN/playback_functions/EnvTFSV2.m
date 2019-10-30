function [Env_sum, Tfs_sum] = EnvTFSV2(in, noiseCarrier, CF, fs)
out = hilbert(in);
Env = real(out);
Env_sum = Env.*noiseCarrier;
Tfs = cos(angle(out));
Tfs_sum = Tfs.*rms(in);
end