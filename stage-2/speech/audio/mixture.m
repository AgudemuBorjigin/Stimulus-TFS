function mixture(stim_tar, stim_masker, b, configuration, SNR, id_trial, target, wordlist, t_mskonset, fs, rampdur, root_audios) %#ok<INUSL>
% masker starts after the prompt for target 
stim_masker = filter(b, 1, stim_masker);
stim_masker = [zeros(t_mskonset*fs, 1); stim_masker];
stim_masker = sigNorm(stim_masker);
stim_tar = [stim_tar; zeros(length(stim_masker) - length(stim_tar), 1)];
stim_tar = sigNorm(stim_tar);

if strcmp(configuration, 'anechoic')
    mix = db2mag(-SNR)*stim_masker + stim_tar;
elseif strcmp(configuration, 'pitch')
    load('h_barMonsieurRichard.mat');
    mix = db2mag(-SNR)*stim_masker + stim_tar;
    mix_echo = conv(mix(t_mskonset*fs:end),h');
    mix_echo = sigNorm(mix_echo);
    mix = [mix(1:t_mskonset*fs-1); mix_echo];
elseif strcmp(configuration, 'space')
    load('h_barMonsieurRichard.mat');
    stim_masker = -stim_masker;
    mix = db2mag(-SNR)*stim_masker + stim_tar;
    mix_echo = conv(mix(t_mskonset*fs:end),h');
    mix_echo = sigNorm(mix_echo);
    mix = [mix(1:t_mskonset*fs-1); mix_echo];
elseif strcmp(configuration, 'echo')
    load('h_barMonsieurRichard.mat');
    mix = db2mag(-SNR)*stim_masker + stim_tar;
    mix_echo = conv(mix(t_mskonset*fs:end),h');
    mix_echo = sigNorm(mix_echo);
    mix = [mix(1:t_mskonset*fs-1); mix_echo];
elseif strcmp(configuration, 'sum')
    stim_masker = -stim_masker;
    mix = db2mag(-SNR)*stim_masker + stim_tar;
end

mix = scaleSound(mix); 
mix  = rampsound(mix, fs, rampdur);
y = [mix, mix]; %#ok<NASGU>

savename = [root_audios, '/mixture/', configuration, '/trial', id_trial, '.mat'];
save(savename, 'y', 'fs', 'SNR', 'target', 'wordlist');
end