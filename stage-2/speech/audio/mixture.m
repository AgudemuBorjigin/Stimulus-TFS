function mixture(stim_tar, stim_masker, b, configuration, SNR, id_trial, target, wordlist, t_mskonset, fs, rampdur, root_audios, v) %#ok<INUSL>
normval = 0.01; 
stim_masker = filter(b, 1, stim_masker);
[h, fs_rev] = audioread('BarMonsieurRicard.wav');
h = resample(h, fs, fs_rev); % resample to 48828 Hz
% masker starts after the prompt for target
stim_masker_left = singleChan(stim_masker, configuration, h(:,1), normval, SNR, t_mskonset, fs, 'masker');
stim_masker_right = singleChan(stim_masker, configuration, h(:,2), normval, SNR, t_mskonset, fs, 'masker');

stim_tar_left = singleChan(stim_tar, configuration, h(:,1), normval, SNR, t_mskonset, fs, 'target');
stim_tar_right = singleChan(stim_tar, configuration, h(:,2), normval, SNR, t_mskonset, fs, 'target');

[stim_masker_left, stim_tar_left] = zeroPadding(stim_masker_left, stim_tar_left);
[stim_masker_right, stim_tar_right] = zeroPadding(stim_masker_right, stim_tar_right);

switch configuration
    case {'anechoic', 'pitch', 'echo', 'echo-pitch'}
        mix_left = stim_tar_left + stim_masker_left;
        mix_right = stim_tar_right + stim_masker_right;
    otherwise
        mix_left = -stim_tar_left + stim_masker_left; % N0S_pi
        mix_right = stim_tar_right + stim_masker_right;
end
mix_left  = rampsound(mix_left, fs, rampdur);
mix_right  = rampsound(mix_right, fs, rampdur);
y = [mix_left, mix_right];  %#ok<NASGU>

savename = [root_audios, '/mixture/', strcat('visit-', num2str(v)), '/trial', id_trial, '.mat'];
save(savename, 'configuration', 'y', 'SNR', 'target', 'wordlist');
end