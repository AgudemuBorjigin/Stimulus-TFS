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

% Exclude M5 because of different naming convention of files, also because
% of very low-pitch sound quality
speakers_target = {'F1', 'F2', 'F3', 'F4', 'M1', 'M2', 'M3', 'M4'};
speakers_target = speakers_target(randi(numel(speakers_target), [1, totaltrials]));
% STOPPED HERE
% separately grouping all female and male speakers from Harvard sentences
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';
speaker_files = dir(strcat(root_audios, '/harvard_sentences'));
speakers_masker = {speaker_files.name};
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
            speakers_same{i, j} = speakers_masker_f{j};   %#ok<AGROW>
            speakers_opposite{i, j} = speakers_masker_m{j};  %#ok<AGROW>
        end
    elseif ~isempty(strfind(speakers_target{i}, 'M'))
        for j = 1:num_interferer
            speakers_same{i, j} = speakers_masker_m{j};
            speakers_opposite{i, j} = speakers_masker_f{j};
        end
    end
end

% the names of the txt files of masker sentences across trials
sentences_files = dir(strcat(root_audios, '/harvard_sentences/transcripts/*.txt'));
sentences = {sentences_files.name};
for i = 1:num_target
    sentences_temp = sentences(randperm(numel(sentences)));
    for j = 1:num_interferer
        sentences_mix_temp = sentences_temp{j};
        sentences_mix{i, j} = sentences_mix_temp(1:end-4);  %#ok<AGROW> % excluding .txt file extension
    end
end

% final audio names containing speaker ID and sentence txt file name, for
% extracting audios
for i = 1:num_target
    for j = 1:num_interferer
        audio_name_same{i, j} = strcat(speakers_same{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
        audio_name_opposite{i, j} = strcat(speakers_opposite{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<AGROW>
    end
end

% mixing audio signals to generate masker
for i = 1:num_target
    speakers_male_temp = speakers_masker_m;
    speakers_female_temp = speakers_masker_f;
    % creating pool of speakers excluding current mixture of speakers for
    % replacement in case a certain speaker in the original
    % mixture did not record the chosen sentence
    for j = 1:num_interferer
        speaker_same_temp = speakers_same{i, j};
        speaker_opposite_temp = speakers_opposite{i, j};
        if strcmp(speaker_same_temp(3), 'F')
            speakers_female_temp(strcmp(speakers_female_temp, speaker_same_temp)) = [];
            speakers_male_temp(strcmp(speakers_male_temp, speaker_opposite_temp)) = [];
        else
            speakers_male_temp(strcmp(speakers_male_temp, speaker_same_temp)) = [];
            speakers_female_temp(strcmp(speakers_female_temp, speaker_opposite_temp)) = [];
        end
    end
    
    for j = 1:num_interferer
        audio_name_temp = audio_name_same{i, j};
        txt_name_same{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        speaker_name_same{j} = speakers_same{i, j};  %#ok<AGROW>
        dir_temp = strcat(root_audios, '/harvard_sentences/', speakers_same{i, j},...
            '/audio/', audio_name_temp);
        while ~exist(dir_temp, 'file') % not every speaker recorded every sentence
            if strcmp(audio_name_temp(3), 'F')
                speaker_temp = speakers_female_temp{randi(numel(speakers_female_temp))};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name_temp(7:end));
            else
                speaker_temp = speakers_male_temp{randi(numel(speakers_male_temp))};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name_temp(7:end));
            end
            speaker_name_same{j} = speaker_temp;
        end
        stim_same_temp = resample(audioread(dir_temp), 4069, 4000);
        stim_same_temp = scaleSound(stim_same_temp);
        
        audio_name_temp = audio_name_opposite{i, j};
        txt_name_opposite{j} = audio_name_temp(8:end-4);  %#ok<AGROW,NASGU>
        speaker_name_opposite{j} = speakers_opposite{i, j};  %#ok<AGROW>
        dir_temp = strcat(root_audios, '/harvard_sentences/', speakers_opposite{i, j},...
            '/audio/', audio_name_temp);
        while ~exist(dir_temp, 'file')
            if strcmp(audio_name_temp(3), 'F')
                speaker_temp = speakers_female_temp{randi(numel(speakers_female_temp))};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name_temp(7:end));
            else
                speaker_temp = speakers_male_temp{randi(numel(speakers_male_temp))};
                dir_temp = strcat(root_audios, '/harvard_sentences/', speaker_temp,...
                    '/audio/', speaker_temp, audio_name_temp(7:end));
            end
            speaker_name_opposite{j} = speaker_temp;
        end
        stim_opposite_temp = resample(audioread(dir_temp), 4069, 4000);
        stim_opposite_temp = scaleSound(stim_opposite_temp);
        
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
    save(savename, 'stim_tar', 'stim_same', 'target', 'wordlist', 'txt_name_same', 'speaker_name_same');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar', 'stim_opposite', 'target', 'wordlist', 'txt_name_opposite', 'speaker_name_opposite');
end
end

