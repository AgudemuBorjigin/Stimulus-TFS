function mixture(target, masker, configuration, SNR, id_trial, num_tar, wordlist, t_mskonset, fs, rampdur, root_audios) %#ok<INUSL>
% masker starts after the prompt for target 
masker = [zeros(t_mskonset*fs, 1); masker];
masker = sigNorm(masker);
target = [target; zeros(length(masker) - length(target), 1)];
target = sigNorm(target);

if strcmp(configuration, 'ref')
    mix = db2mag(-SNR)*masker + target;
elseif strcmp(configuration, 'pitch')
    mix = db2mag(-SNR)*masker + target;
elseif strcmp(configuration, 'space')
    
elseif strcmp(configuration, 'echo')
    
elseif strcmp(configuration, 'sum')
    
end

mix = scaleSound(mix); 
mix  = rampsound(mix, fs, rampdur);
mix = [mix, mix]; %#ok<NASGU>

savename = [root_audios, '/mixture/', configuration, '/trial', id_trial, '.mat'];
save(savename, 'mix', 'fs', 'SNR', 'num_tar', 'wordlist');
end