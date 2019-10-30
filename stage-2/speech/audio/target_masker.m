wordlists = 1:50;
nwordsperlist = 6;
nlists = numel(wordlists);
% CHANGE AS NEEDED
N = [50, 50, 50, 50, 50, 50]; % Number of trials per SNR (variable), make sure the sum is divisible by 6, nSNRs, and 50
totaltrials = sum(N);

% CHANGE AS NEEDED: setting random generator seed and state
load('s.mat'); rng(s);

targets = repmat(1:nwordsperlist, 1, (totaltrials/nwordsperlist));
targets = targets(randperm(totaltrials));

% The commented code below does not guarantee even distribution
% wordlists = wordlists(randi(numel(wordlists), [1, totaltrials]));
wordlists = repmat(1:nlists, 1, (totaltrials/nlists));
wordlists = wordlists(randperm(totaltrials));

% Exclude M5 because of different naming convention of files and to balance
% male and female voices.
% speakers = speakers(randi(numel(speakers), [1, totaltrials]));
speakers_target = {'F1', 'F2', 'F3', 'M1', 'M2', 'M3'};
ind_speaker = repmat(1:numel(speakers_target), 1, (totaltrials/numel(speakers_target)));
ind_speaker = ind_speaker(randperm(totaltrials));
speakers_target = speakers_target(ind_speaker);

% grouping all female and male speakers from Harvard sentences
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';
speaker_dir = dir(strcat(root_audios, '/harvard_sentences'));
speakers_masker = {speaker_dir.name};
count_f = 0; count_m = 0;
for i = 1:numel(speakers_masker)
    if ~isempty(strfind(speakers_masker{i}, 'F'))
        count_f = count_f + 1;
        speakers_female{count_f} = speakers_masker{i};  %#ok<SAGROW>
    elseif ~isempty(strfind(speakers_masker{i}, 'M'))
        count_m = count_m + 1;
        speakers_male{count_m} = speakers_masker{i};  %#ok<SAGROW>
    end
end

% creating randomized mixture of 4 female and male speakers. 
% for pitch configuration, pitch difference between target and masker is
% difficult to equalized across trials, therefore it's better to
% randomized the mixture across trials
num_interferer = 4;
num_target = numel(speakers_target);
for i = 1:num_target
    speakers_male = speakers_male(randperm(numel(speakers_male)));
    speakers_female = speakers_female(randperm(numel(speakers_female)));
    if ~isempty(strfind(speakers_target{i}, 'F'))
        for j = 1:num_interferer
            speakers_same{i, j} = speakers_female{j};  %#ok<SAGROW>
            speakers_opposite{i, j} = speakers_male{j}; %#ok<SAGROW>
        end
    elseif ~isempty(strfind(speakers_target{i}, 'M'))
        for j = 1:num_interferer
            speakers_same{i, j} = speakers_male{j};
            speakers_opposite{i, j} = speakers_female{j};
        end 
    end
end

% sentences for maskers across trials
sentences_dir = dir(strcat(root_audios, '/harvard_sentences/transcripts/*.txt'));
sentences = {sentences_dir.name};
for i = 1:num_target
    sentences_temp = sentences(randperm(numel(sentences)));
    for j = 1:num_interferer
        sentences_mix_temp = sentences_temp{j}; 
        sentences_mix{i, j} = sentences_mix_temp(1:end-4); %#ok<SAGROW>
    end
end

% final audio names containing speaker ID and sentence name
for i = 1:num_target
    for j = 1:num_interferer
        audio_name_same{i, j} = strcat(speakers_same{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<SAGROW>
        audio_name_opposite{i, j} = strcat(speakers_opposite{i, j}, '_', sentences_mix{i, j}, '.wav'); %#ok<SAGROW>
    end
end

% mixing audio signals for masker
for i = 1:num_target
    speakers_male_temp = speakers_male;
    speakers_female_temp = speakers_female;
    % creating pool of speakers excluding current mixture of speakers for
    % back up 
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
        txt_name_same{j} = audio_name_temp(8:end-4); %#ok<SAGROW>
        speaker_name_same{j} = speakers_same{i, j}; %#ok<SAGROW>
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
        
        audio_name_temp = audio_name_opposite{i, j};
        txt_name_opposite{j} = audio_name_temp(8:end-4); %#ok<SAGROW>
        speaker_name_opposite{j} = speakers_opposite{i, j}; %#ok<SAGROW>
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
        
        if j > 1
            if stim_same_len < length(stim_same_temp)
                stim_same = [stim_same;zeros(length(stim_same_temp) - stim_same_len, 1)]; %#ok<AGROW>
            elseif stim_same_len > length(stim_same_temp)
                stim_same_temp = [stim_same_temp;zeros(stim_same_len - length(stim_same_temp), 1)]; %#ok<AGROW>
            else
            end
            if stim_opposite_len < length(stim_opposite_temp)
               stim_opposite = [stim_opposite;zeros(length(stim_opposite_temp) - stim_opposite_len, 1)]; %#ok<AGROW>
            elseif stim_opposite_len > length(stim_opposite_temp)
               stim_opposite_temp = [stim_opposite_temp;zeros(stim_opposite_len - length(stim_opposite_temp), 1)]; %#ok<AGROW>
            else  
            end
            stim_same_len = length(stim_same_temp); 
            stim_opposite_len = length(stim_opposite_temp);
            stim_same = stim_same + stim_same_temp;
            stim_opposite = stim_opposite + stim_opposite_temp;
        else
            stim_same = stim_same_temp;
            stim_opposite = stim_opposite_temp;
            stim_same_len = length(stim_same_temp); 
            stim_opposite_len = length(stim_opposite_temp);
        end
    end
    
    stim_opposite = stim_opposite/num_interferer;
    stim_same = stim_same/num_interferer;
    
    % extracting and saving audio files for target and masker 
    wordlist = wordlists(i);
    target = targets(i);
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target);
    stim_tar = resample(audioread(fname_tar), 4069, 4000);
    
    savename = [root_audios, '/target_masker/same_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar', 'stim_same', 'target', 'wordlist', 'txt_name_same', 'speaker_name_same');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar', 'stim_opposite', 'target', 'wordlist', 'txt_name_opposite', 'speaker_name_opposite');
end
    
