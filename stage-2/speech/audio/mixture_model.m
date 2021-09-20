function mixture_model(stim_tar, stim_masker, b, configuration, SNR, id_trial, target, wordlist, t_mskonset, fs, rampdur, root_audios, v)
normval = 0.01;
stim_masker = filter(b, 1, stim_masker);
% preprocessing: normalization, ramping masker, onset delay for maskers,
% snr adjustments for masker
stim_masker_left = singleChan(stim_masker, normval, SNR, t_mskonset, fs, rampdur, 'masker');
stim_masker_right = singleChan(stim_masker, normval, SNR, t_mskonset, fs, rampdur, 'masker');
stim_tar_left = singleChan(stim_tar, normval, SNR, t_mskonset, fs, rampdur, 'target');
stim_tar_right = singleChan(stim_tar, normval, SNR, t_mskonset, fs, rampdur, 'target');
% making the length of the masker and target the same for mixing
[stim_masker_left, stim_tar_left] = zeroPadding(stim_masker_left, stim_tar_left);
[stim_masker_right, stim_tar_right] = zeroPadding(stim_masker_right, stim_tar_right);

switch configuration
    case {'anechoic', 'pitch', 'echo', 'echo-pitch'}
        mix_left = stim_tar_left + stim_masker_left;
        mix_right = stim_tar_right + stim_masker_right;
        if strcmp(configuration, 'echo') || strcmp(configuration, 'echo-pitch')
            [h, fs_rev] = audioread('BarMonsieurRicard.wav');
            h = resample(h, fs, fs_rev); % resample to 48828 Hz
            mix_left = sigNorm(conv(mix_left, h(:,1)));
            mix_right = sigNorm(conv(mix_right, h(:,2)));
        end
        mix_left = mix_left(1:(length(stim_tar) + 2500), 1);
        mix_right = mix_right(1:(length(stim_tar) + 2500), 1);
        mix_left  = rampsound(mix_left, fs, rampdur);
        mix_right  = rampsound(mix_right, fs, rampdur);
        y = [sigNorm(mix_left), sigNorm(mix_right)];
    case {'space', 'sum', 'echo-space', 'echo-sum'}
        mix_left = -stim_tar_left + stim_masker_left; % N0S_pi
        mix_right = stim_tar_right + stim_masker_right;
        if contains(configuration, 'echo')
            [h, fs_rev] = audioread('BarMonsieurRicard.wav');
            h = resample(h, fs, fs_rev); % resample to 48828 Hz
            mix_left = sigNorm(conv(mix_left, h(:,1)));
            mix_right = sigNorm(conv(mix_right, h(:,2)));
        end
        mix_left = mix_left(1:(length(stim_tar) + 2500), 1);
        mix_right = mix_right(1:(length(stim_tar) + 2500), 1);
        mix_left  = rampsound(mix_left, fs, rampdur);
        mix_right  = rampsound(mix_right, fs, rampdur);
        y = [sigNorm(mix_left), sigNorm(mix_right)];
    case {'noise', 'echo-noise'}
        [mix, ~, ~] = stonemoore2014(stim_tar, t_mskonset, fs, SNR, rampdur);
        if contains(configuration, 'echo')
            [h, fs_rev] = audioread('BarMonsieurRicard.wav');
            h = resample(h, fs, fs_rev); % resample to 48828 Hz
            mix_left = sigNorm(conv(mix(:,1), h(:,1)));
            mix_right = sigNorm(conv(mix(:,2), h(:,2)));
            mix_left = mix_left(1:(length(stim_tar) + 2500), 1);
            mix_right = mix_right(1:(length(stim_tar) + 2500), 1);
            mix_left  = rampsound(mix_left, fs, rampdur);
            mix_right  = rampsound(mix_right, fs, rampdur);
            y = [mix_left, mix_right];
        else
            mix_left = mix(:, 1);
            mix_right = mix(:, 2);
            y = [mix_left, mix_right];
        end
    case {'ref', 'echo-ref'}
        mix_left = stim_tar_left + stim_masker_left;
        mix_right = stim_tar_right + stim_masker_right;
        if contains(configuration, 'echo')
            [h, fs_rev] = audioread('BarMonsieurRicard.wav');
            h = resample(h, fs, fs_rev); % resample to 48828 Hz
            mix_left = sigNorm(conv(mix_left, h(:,1)));
            mix_right = sigNorm(conv(mix_right, h(:,2)));
        end
        mix_left = mix_left(1:(length(stim_tar) + 2500), 1);
        mix_right = mix_right(1:(length(stim_tar) + 2500), 1);
        mix_left  = rampsound(mix_left, fs, rampdur);
        mix_right  = rampsound(mix_right, fs, rampdur);
        y = [sigNorm(mix_left), sigNorm(mix_right)];
    case {'target'}
        y = [rampsound(stim_tar_left, fs, rampdur), rampsound(stim_tar_right, fs, rampdur)];
end
%% for model
if contains(configuration, 'noise')
    [~, stim_tar_model, stim_masker_model] = stonemoore2014(stim_tar, t_mskonset, fs, SNR, rampdur);
    stim_masker_model = singleChan(stim_masker_model, normval, 0, t_mskonset, fs, rampdur, 'masker');
    stim_tar_model = singleChan(stim_tar_model, normval, 0, t_mskonset, fs, rampdur, 'target');
    stim_tar_model  = rampsound(stim_tar_model, fs, rampdur); 
else
    stim_masker_model = singleChan(stim_masker, normval, 0, t_mskonset, fs, rampdur, 'masker');
    stim_tar_model = singleChan(stim_tar, normval, 0, t_mskonset, fs, rampdur, 'target');
    stim_tar_model  = rampsound(stim_tar_model, fs, rampdur);       
end
[stim_masker_model, stim_tar_model] = zeroPadding(stim_masker_model, stim_tar_model);
%% save
savename = [root_audios, '/mixture/', strcat('visit-', num2str(v)), '/trial', id_trial, '.mat'];
save(savename, 'configuration', 'y', 'SNR', 'target', 'wordlist', 'stim_tar_model', 'stim_masker_model');
end