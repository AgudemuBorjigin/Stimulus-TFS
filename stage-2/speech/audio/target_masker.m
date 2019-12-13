function target_masker(totaltrials, count)
wordlists = 1:50;
targets = 1:6;

% Setting random generator seed and state, not needed for
% different randomization
% load('s.mat'); rng(s);

% this randomization guarentees equal distribution of each element 
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
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';

speakers_masker_f = {'NCF011', 'NCF015', 'PNF139', 'PNF142', 'PNF135', 'NCF012'};
speakers_masker_m = {'NCM012', 'NCM017', 'PNM078', 'PNM086', 'PNM082', 'NCM015'};
% assigning masker speakers to the target speakers according to gender
num_interferer = 4;
num_target = numel(speakers_target);
for i = 1:num_target
    if ~isempty(strfind(speakers_target{i}, 'F'))
        for j = 1:num_interferer
            maskers_same{i, j} = speakers_masker_f{j};   %#ok<AGROW>
            maskers_opposite{i, j} = speakers_masker_m{j};  %#ok<AGROW>
        end
    elseif ~isempty(strfind(speakers_target{i}, 'M'))
        for j = 1:num_interferer
            maskers_same{i, j} = speakers_masker_m{j};
            maskers_opposite{i, j} = speakers_masker_f{j};
        end
    end
end

% the names of the txt files of masker sentences across trials
sentences_files = dir(strcat(root_audios, '/harvard_sentences/transcripts/*.txt'));
sentences_name = {sentences_files.name};
sentences_name_index = equalDistribution(totaltrials*num_interferer, numel(sentences_name));
sentences_name = sentences_name(sentences_name_index);
for i = 1:num_target
    for j = 1:num_interferer
        sentences_mix_temp = sentences_name{(i-1)*num_interferer + j};
        sentences_mix{i, j} = sentences_mix_temp(1:end-4);  %#ok<AGROW> % excluding .txt file extension
    end
end

% final audio names containing speaker ID and sentence txt file name
for i = 1:num_target
    for j = 1:num_interferer
        audio_name_same{i, j} = strcat(maskers_same{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
        audio_name_opposite{i, j} = strcat(maskers_opposite{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
    end
end

% mixing audio signals to generate masker
for i = 1:num_target
    % back up speakers just in case a speaker did not record a particular
    % sentence
    maskers_male_bck = speakers_masker_m((num_interferer+1):end);
    maskers_female_bck = speakers_masker_f((num_interferer+1):end);
    
    for j = 1:num_interferer
        
        % reading audio files for the maskers
        audio_name_temp = audio_name_same{i, j};
        maskers_name_same{j} = maskers_same{i, j};  %#ok<AGROW>
        txt_name_same{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        stim_same_temp = readMaskerAudios(root_audios, audio_name_temp, maskers_name_same{j}, maskers_female_bck, maskers_male_bck);
        
        audio_name_temp = audio_name_opposite{i, j};
        maskers_name_opposite{j} = maskers_opposite{i, j};  %#ok<AGROW>
        txt_name_opposite{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        stim_opposite_temp = readMaskerAudios(root_audios, audio_name_temp, maskers_name_opposite{j}, maskers_female_bck, maskers_male_bck);
        
        if j > 1
            if length(stim_same) < length(stim_same_temp)
                stim_same = centering(stim_same_temp, stim_same);
            else
                stim_same_temp = centering(stim_same, stim_same_temp);
            end
            if length(stim_opposite) < length(stim_opposite_temp)
                stim_opposite = centering(stim_opposite_temp, stim_opposite);
            else
                stim_opposite_temp = centering(stim_opposite, stim_opposite_temp);
            end
            stim_same = stim_same + stim_same_temp;
            stim_opposite = stim_opposite + stim_opposite_temp;
        else
            stim_same = stim_same_temp;
            stim_opposite = stim_opposite_temp;
        end
    end
    
    stim_opposite = scaleSound(stim_opposite);
    stim_same = scaleSound(stim_same);
    
    % extracting audio file for target and saving target and masker
    wordlist = wordlists(i);
    target = targets(i);
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target);
    stim_tar = resample(audioread(fname_tar), 4069, 4000); 
    stim_tar = scaleSound(stim_tar); %#ok<NASGU>
    tar_gender = speakers_target{i}; %#ok<NASGU>
    
    savename = [root_audios, '/target_masker/same_gender/trial', num2str(count+i), '.mat'];
    save(savename, 'stim_tar', 'stim_same', 'target', 'wordlist', 'txt_name_same', 'maskers_name_same', 'tar_gender');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(count+i), '.mat'];
    save(savename, 'stim_tar', 'stim_opposite', 'target', 'wordlist', 'txt_name_opposite', 'maskers_name_opposite', 'tar_gender');
end
end

