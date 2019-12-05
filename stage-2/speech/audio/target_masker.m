function target_masker(totaltrials)
wordlists = 1:50;
nlists = numel(wordlists);
targets = 1:6;
nwordsperlist = 6;

% CHANGE AS NEEDED: setting random generator seed and state, not needed for
% different randomization
% load('s.mat'); rng(s);

targets = targets(randi(nwordsperlist, [1, totaltrials]));

% this randomization guarentees equal distribution of each element in
% wordlists
if fix(totaltrials/nlists) < 1
    wordlists = 1:totaltrials;
else
    wordlists = repmat(1:nlists, 1, fix(totaltrials/nlists));
    wordlists = [wordlists, 1:mod(totaltrials,nlists)];
end
wordlists = wordlists(randperm(totaltrials));

% fixed speaker for male and female voice
speakers_target = {'F1', 'M1'};
speakers_target = speakers_target(randi(numel(speakers_target), [1, totaltrials]));

% STOPPED HERE - AB: 12/04/2019
% separately grouping all female and male speakers from Harvard sentences
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';
masker_files = dir(strcat(root_audios, '/harvard_sentences'));
speakers_masker = {masker_files.name};
count_f = 0; count_m = 0;
for i = 1:numel(speakers_masker)
    if ~isempty(strfind(speakers_masker{i}, 'F'))
        count_f = count_f + 1;
        speakers_masker_f{count_f} = speakers_masker{i};  %#ok<AGROW>
    elseif ~isempty(strfind(speakers_masker{i}, 'M'))
        count_m = count_m + 1;
        speakers_masker_m{count_m} = speakers_masker{i};   %#ok<AGROW>
    end
end

% creating randomized mixture of 4 female and male speakers.
% for pitch configuration, pitch difference between target and masker is
% difficult to equalized across trials, therefore it's better to
% randomized the mixture across trials
num_interferer = 4;
num_target = numel(speakers_target);
for i = 1:num_target
    speakers_masker_m = speakers_masker_m(randperm(numel(speakers_masker_m)));
    speakers_masker_f = speakers_masker_f(randperm(numel(speakers_masker_f)));
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
for i = 1:num_target
    sentences_temp = sentences_name(randperm(numel(sentences_name)));
    for j = 1:num_interferer
        sentences_mix_temp = sentences_temp{j};
        sentences_mix{i, j} = sentences_mix_temp(1:end-4);  %#ok<AGROW> % excluding .txt file extension
    end
end

% final audio names containing speaker ID and sentence txt file name, for
% extracting audios
for i = 1:num_target
    for j = 1:num_interferer
        audio_name_same{i, j} = strcat(maskers_same{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
        audio_name_opposite{i, j} = strcat(maskers_opposite{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
    end
end

% mixing audio signals to generate masker
for i = 1:num_target
    maskers_male_temp = speakers_masker_m;
    maskers_female_temp = speakers_masker_f;
    % creating pool of speakers excluding current mixture of speakers for
    % replacement in case a certain speaker in the original
    % mixture did not record the chosen sentence
    for j = 1:num_interferer
        speaker_same_temp = maskers_same{i, j};
        speaker_opposite_temp = maskers_opposite{i, j};
        if strcmp(speaker_same_temp(3), 'F')
            maskers_female_temp(strcmp(maskers_female_temp, speaker_same_temp)) = [];
            maskers_male_temp(strcmp(maskers_male_temp, speaker_opposite_temp)) = [];
        else
            maskers_male_temp(strcmp(maskers_male_temp, speaker_same_temp)) = [];
            maskers_female_temp(strcmp(maskers_female_temp, speaker_opposite_temp)) = [];
        end
    end
    
    for j = 1:num_interferer
        
        % reading audio files for the maskers
        audio_name_temp = audio_name_same{i, j};
        maskers_name_same{j} = maskers_same{i, j};  %#ok<AGROW>
        txt_name_same{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        stim_same_temp = readMaskerAudios(root_audios, audio_name_temp, maskers_name_same{j}, maskers_female_temp, maskers_male_temp);
        
        audio_name_temp = audio_name_opposite{i, j};
        maskers_name_opposite{j} = maskers_opposite{i, j};  %#ok<AGROW>
        txt_name_opposite{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        stim_opposite_temp = readMaskerAudios(root_audios, audio_name_temp, maskers_name_opposite{j}, maskers_female_temp, maskers_male_temp);
        
        if j > 1
            if length(stim_same) < length(stim_same_temp)
                stim_same = centering(stim_same_temp, stim_same);
            elseif length(stim_same) > length(stim_same_temp)
                stim_same_temp = centering(stim_same, stim_same_temp);
            else
            end
            if length(stim_opposite) < length(stim_opposite_temp)
                stim_opposite = centering(stim_opposite_temp, stim_opposite);
            elseif length(stim_opposite) > length(stim_opposite_temp)
                stim_opposite_temp = centering(stim_opposite, stim_opposite_temp);
            else
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
    
    % extracting and saving audio files for target and masker
    wordlist = wordlists(i);
    target = targets(i);
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target);
    stim_tar = resample(audioread(fname_tar), 4069, 4000); 
    stim_tar = scaleSound(stim_tar); %#ok<NASGU>
    
    savename = [root_audios, '/target_masker/same_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar', 'stim_same', 'target', 'wordlist', 'txt_name_same', 'maskers_name_same');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar', 'stim_opposite', 'target', 'wordlist', 'txt_name_opposite', 'maskers_name_opposite');
end
end

