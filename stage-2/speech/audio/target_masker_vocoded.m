function target_masker_vocoded(totaltrials, count, fs, root_audios)
wordlists = 1:50;
targets = 1:6;
% Setting random generator seed and state, not needed for
% different randomization
% load('s.mat'); rng(s);

% this randomization guarentees relatively equal distribution of each element 
targets = equalDistribution(totaltrials, numel(targets));
targets = targets(randperm(totaltrials));

wordlists = equalDistribution(totaltrials, numel(wordlists));
wordlists = wordlists(randperm(totaltrials));

% fixed speaker for male and female voice
speakers_target = {'F1', 'M1'};
speakers_target_index = equalDistribution(totaltrials, numel(speakers_target));
speakers_target = speakers_target(speakers_target_index);
speakers_target = speakers_target(randperm(totaltrials));

% separately grouping all female and male speakers from Harvard sentences
speakers_masker_f = {'NCF011', 'NCF015', 'PNF139', 'PNF142'};
speakers_masker_m = {'NCM012', 'NCM017', 'PNM078', 'PNM086'};
audiofiles_f = cell(1, numel(speakers_masker_f));
audiofiles_m = cell(1, numel(speakers_masker_m));
for i = 1:numel(speakers_masker_f)
    audiofiles_f{i} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_f{i}, '/audio/*.wav'));
    audiofiles_m{i} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_m{i}, '/audio/*.wav'));
end
% assigning masker speakers to the target speakers according to gender
num_interferer = 4;
num_target = numel(speakers_target);
for i = 1:num_target
    if ~isempty(strfind(speakers_target{i}, 'F'))
        for j = 1:num_interferer
            maskers_same_gender{i, j} = speakers_masker_f{j};   %#ok<AGROW>
            maskers_opposite_gender{i, j} = speakers_masker_m{j};  %#ok<AGROW>
        end
    elseif ~isempty(strfind(speakers_target{i}, 'M'))
        for j = 1:num_interferer
            maskers_same_gender{i, j} = speakers_masker_m{j};
            maskers_opposite_gender{i, j} = speakers_masker_f{j};
        end
    end
end

%% 
% to make the masker unintelligeble, nfilts number of senstences from a speaker are chosen as inputs
% to nfilts number of filter bands, outputs of which are then mixed to
% generate one masker 
nfilts = 16;
for i = 1:num_target
    if ~isempty(strfind(speakers_target{i}, 'F'))
        for j = 1:num_interferer
            audio_names_same{i, j} = rand_elements({audiofiles_f{j}.name}, nfilts); %#ok<AGROW>
            audio_names_opposite{i, j} = rand_elements({audiofiles_m{j}.name}, nfilts); %#ok<AGROW>
        end
    elseif ~isempty(strfind(speakers_target{i}, 'M'))   
        for j = 1:num_interferer
            audio_names_opposite{i, j} = rand_elements({audiofiles_f{j}.name}, nfilts);
            audio_names_same{i, j} = rand_elements({audiofiles_m{j}.name}, nfilts);
        end
    end
end

% mixing audio signals to generate masker
f_low = 80;
f_high = 16000;
for i = 1:num_target 
    if ~isempty(strfind(speakers_target{i}, 'F'))
        gender_same = 'F';
        gender_opposite = 'M';
    else
        gender_same = 'M';
        gender_opposite = 'F';
    end
    
    for j = 1:num_interferer
        stim_same_temp = sig_vocode(audio_names_same{i, j}, fs, f_low, f_high, root_audios, gender_same, 1);
        stim_opposite_temp = sig_vocode(audio_names_opposite{i, j}, fs, f_low, f_high, root_audios, gender_opposite, 1);
        if j == 1
            stim_same = stim_same_temp;
            stim_opposite = stim_opposite_temp;
        else
            [stim_same_temp, stim_same] = centering(stim_same_temp, stim_same);
            [stim_opposite_temp, stim_opposite] = centering(stim_opposite_temp, stim_opposite);
            stim_same = stim_same + stim_same_temp;
            stim_opposite = stim_opposite + stim_opposite_temp;
        end
    end
    stim_opposite = sigNorm(stim_opposite);
    stim_same = sigNorm(stim_same);
    
    % extracting audio file for target and saving target and masker
    wordlist = wordlists(i);
    target = targets(i);
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target);
    if ~isempty(strfind(speakers_target{i}, 'F'))
        gender = 'F';
    else
        gender = 'M';
    end
    stim_tar = sig_vocode(fname_tar, fs, f_low, f_high, root_audios, gender, 0);
    tar_gender = speakers_target{i}; 
    
    savename = [root_audios, '/target_masker/same_gender/trial', num2str(count+i), '.mat'];
    save(savename, 'stim_tar', 'stim_same', 'target', 'wordlist', 'tar_gender', 'fs');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(count+i), '.mat'];
    save(savename, 'stim_tar', 'stim_opposite', 'target', 'wordlist', 'tar_gender', 'fs');

end
end

