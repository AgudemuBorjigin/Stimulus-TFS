function mixture(stim_tar, stim_masker, configuration, SNR, id_trial, target, wordlist, t_mskonset, fs, rampdur, root_audios) %#ok<INUSL>
% masker starts after the prompt for target 
stim_masker = [zeros(t_mskonset*fs, 1); stim_masker];
stim_masker = sigNorm(stim_masker);
stim_tar = [stim_tar; zeros(length(stim_masker) - length(stim_tar), 1)];
stim_tar = sigNorm(stim_tar);

if strcmp(configuration, 'ref')
    mix = db2mag(-SNR)*stim_masker + stim_tar;
elseif strcmp(configuration, 'pitch')
    mix = db2mag(-SNR)*stim_masker + stim_tar;
elseif strcmp(configuration, 'space')
    
elseif strcmp(configuration, 'echo')
    
elseif strcmp(configuration, 'sum')
    
end

mix = scaleSound(mix); 
mix  = rampsound(mix, fs, rampdur);
y = [mix, mix]; %#ok<NASGU>

savename = [root_audios, '/mixture/', configuration, '/trial', id_trial, '.mat'];
save(savename, 'y', 'fs', 'SNR', 'target', 'wordlist');
end