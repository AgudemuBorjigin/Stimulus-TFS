function b = target_masker_v2(totaltrials, fs, root_audios)
wordlists = 1:50;
targets = 1:6;
% Setting random generator seed and state, not needed for
% different randomization
% load('s.mat'); rng(s);

% this randomization guarentees relatively equal distribution of each word
% choice and list
if totaltrials < numel(targets)
    targets = rand_elements(targets, totaltrials);
else
    targets = equalDistribution(totaltrials, numel(targets));
    targets = targets(randperm(totaltrials));
end

if totaltrials < numel(wordlists)
    wordlists = rand_elements(wordlists, totaltrials);
else
    wordlists = equalDistribution(totaltrials, numel(wordlists));
    wordlists = wordlists(randperm(totaltrials));
end
% fixed speaker for male and female voice
speakers_target = {'F1', 'M1'};
if totaltrials < numel(speakers_target)
    speakers_target_index = rand_elements(1:numel(speakers_target), totaltrials);
else
    speakers_target_index = equalDistribution(totaltrials, numel(speakers_target));
end
speakers_target = speakers_target(speakers_target_index);
speakers_target = speakers_target(randperm(totaltrials));
num_target = numel(speakers_target);

% separately grouping female and male speakers from Harvard sentences
%speakers_masker_f = {'NCF011', 'NCF015', 'PNF139', 'PNF142', 'NCF014', 'NCF017', 'PNF133', 'PNF140'};
%speakers_masker_m = {'NCM012', 'NCM017', 'PNM078', 'PNM086', 'NCM014', 'NCM018', 'PNM055', 'PNM082'};
speakers_masker_f = {'NCF011', 'NCF015', 'PNF139', 'PNF142'};
speakers_masker_m = {'NCM012', 'NCM017', 'PNM078', 'PNM086'};
audios_flat_f = {'audio_flat_235', 'audio_flat_240', 'audio_flat_250', 'audio_flat_255'};
audios_flat_m = {'audio_flat_85', 'audio_flat_90', 'audio_flat_100', 'audio_flat_105'};
audiofiles_f = cell(1, numel(speakers_masker_f));
audiofiles_m = cell(1, numel(speakers_masker_m));
audiofiles_flat_f = cell(1, numel(speakers_masker_f));
audiofiles_flat_m = cell(1, numel(speakers_masker_m));
for n = 1:numel(speakers_masker_f)
    audiofiles_f{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_f{n}, '/audio/*.wav'));
    audiofiles_m{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_m{n}, '/audio/*.wav'));
    audiofiles_flat_f{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_f{n}, '/', audios_flat_f{n}, '/*.wav'));
    audiofiles_flat_m{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_m{n}, '/', audios_flat_m{n}, '/*.wav'));
end

num_interferer = numel(speakers_masker_f);

nfilts = 64;
f_low = 80;
f_high = 16000;

% To randomly choose one sentence from each speaker, to make the masker unintelligible, nfilts number of
% sentences can be chosen
for n = 1:num_target
    if contains(speakers_target{n}, 'F')
        for j = 1:num_interferer
            audio_names_same{n, j} = rand_elements({audiofiles_flat_f{j}.name}, 1); %#ok<AGROW>
            audio_names_opposite{n, j} = rand_elements({audiofiles_flat_m{j}.name}, 1); %#ok<AGROW>
            audio_names_intact_same{n, j} = rand_elements({audiofiles_f{j}.name}, 1); %#ok<AGROW>
            audio_names_intact_opposite{n, j} = rand_elements({audiofiles_m{j}.name}, 1); %#ok<AGROW>
        end
    elseif contains(speakers_target{n}, 'M')
        for j = 1:num_interferer
            audio_names_opposite{n, j} = rand_elements({audiofiles_flat_f{j}.name}, 1);
            audio_names_same{n, j} = rand_elements({audiofiles_flat_m{j}.name}, 1);
            audio_names_intact_opposite{n, j} = rand_elements({audiofiles_f{j}.name}, 1);
            audio_names_intact_same{n, j} = rand_elements({audiofiles_m{j}.name}, 1);
        end
    end
end

%% extracting target and masker audios
for i = 1:num_target
    % target audio
    wordlist = wordlists(i);
    target = targets(i);
    if contains(speakers_target{i}, 'F')
        %pitch_freq = 235;
        pitch_freq = 245;
    else
        %pitch_freq = 105;
        pitch_freq = 95;
    end
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target, pitch_freq, 1);
    [stim_tar_intact, fs_sig] = audioread(fname_tar);
    stim_tar_intact = resample(stim_tar_intact, fs, fs_sig);
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target, pitch_freq, 0);
    [stim_tar_pitch_flat, fs_sig] = audioread(fname_tar);
    stim_tar_pitch_flat = resample(stim_tar_pitch_flat, fs, fs_sig);
    tar_speaker = speakers_target{i};
    
    % masker audio
    % mixing audio signals to generate masker
    if contains(tar_speaker, 'F')
        %pitch_freqs_opposite = [85, 90, 95, 100, 110, 115, 120, 125];
        %pitch_freqs_same = [215, 220, 225, 230, 240, 245, 250, 255];
        pitch_freqs_opposite = [85, 90, 100, 105];
        pitch_freqs_same = [235, 240, 250, 255];
    else
        %pitch_freqs_same = [85, 90, 95, 100, 110, 115, 120, 125];
        %pitch_freqs_opposite = [215, 220, 225, 230, 240, 245, 250, 255];
        pitch_freqs_same = [85, 90, 100, 105];
        pitch_freqs_opposite = [235, 240, 250, 255];
    end
    for j = 1:num_interferer
        [~, stim_intact_same_temp] = sig_vocode(audio_names_intact_same{i, j}, fs, f_low, f_high, root_audios, 1, nfilts, 0, 0, pitch_freqs_same(j));
        [~, stim_intact_opposite_temp] = sig_vocode(audio_names_intact_opposite{i, j}, fs, f_low, f_high, root_audios, 1, nfilts, 0, 0, pitch_freqs_opposite(j));
        index_underscore = find(audio_names_same{i, j}{1} == '_');
        index_dot = find(audio_names_same{i, j}{1} == '.');
        filePath = strcat(root_audios, '/harvard_sentences/', audio_names_same{i, j}{1}(1:6), '/audio_flat', audio_names_same{i, j}{1}(index_underscore(end):index_dot-1), '/', audio_names_same{i, j}{1});
        [stim_same_temp, fs_sig] = audioread(filePath);
        stim_same_temp = resample(stim_same_temp, fs, fs_sig);
        
        index_underscore = find(audio_names_opposite{i, j}{1} == '_');
        index_dot = find(audio_names_opposite{i, j}{1} == '.');
        filePath = strcat(root_audios, '/harvard_sentences/', audio_names_opposite{i, j}{1}(1:6), '/audio_flat', audio_names_opposite{i, j}{1}(index_underscore(end):index_dot-1), '/', audio_names_opposite{i, j}{1});
        [stim_opposite_temp, fs_sig] = audioread(filePath);
        stim_opposite_temp = resample(stim_opposite_temp, fs, fs_sig);
        
        if j == 1
            stim_same = stim_same_temp;
            stim_opposite = stim_opposite_temp;
            stim_intact_same = stim_intact_same_temp;
            stim_intact_opposite = stim_intact_opposite_temp;
        else
            [stim_same_temp, stim_same] = zeroPadding(stim_same_temp, stim_same);
            [stim_opposite_temp, stim_opposite] = zeroPadding(stim_opposite_temp, stim_opposite);
            [stim_intact_same_temp, stim_intact_same] = zeroPadding(stim_intact_same_temp, stim_intact_same);
            [stim_intact_opposite_temp, stim_intact_opposite] = zeroPadding(stim_intact_opposite_temp, stim_intact_opposite);
            stim_same = stim_same + stim_same_temp;
            stim_opposite = stim_opposite + stim_opposite_temp;
            stim_intact_same = stim_intact_same + stim_intact_same_temp;
            stim_intact_opposite = stim_intact_opposite + stim_intact_opposite_temp;
        end
    end
    stim_opposite = sigNorm(stim_opposite);
    stim_same = sigNorm(stim_same);
    stim_intact_same = sigNorm(stim_intact_same);
    stim_intact_opposite = sigNorm(stim_intact_opposite);
    savename = [root_audios, '/target_masker/same_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_pitch_flat', 'stim_same', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_pitch_flat', 'stim_opposite', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/intact_same_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_intact', 'stim_intact_same', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/intact_opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_intact', 'stim_intact_opposite', 'target', 'wordlist', 'tar_speaker', 'fs');
    
    % taking avg spectrum
    tar_abs = abs(fft(stim_tar_pitch_flat));
    tar_abs_intact = abs(fft(stim_tar_intact));
    bck_abs_intact_same = abs(fft(stim_intact_same));
    bck_abs_intact_opposite = abs(fft(stim_intact_opposite));
    bck_abs_same = abs(fft(stim_same));
    bck_abs_opposite = abs(fft(stim_opposite));
    if i == 1
        tar_abs_avg = tar_abs;
        tar_abs_avg_intact = tar_abs_intact;
        bck_abs_avg_intact_same = bck_abs_intact_same;
        bck_abs_avg_intact_opposite = bck_abs_intact_opposite;
        bck_abs_avg_same = bck_abs_same;
        bck_abs_avg_opposite = bck_abs_opposite;
    else
        [tar_abs, tar_abs_avg] = zeroPadding(tar_abs, tar_abs_avg);
        [tar_abs_intact, tar_abs_avg_intact] = zeroPadding(tar_abs_intact, tar_abs_avg_intact);
        [bck_abs_intact_same, bck_abs_avg_intact_same] = zeroPadding(bck_abs_intact_same, bck_abs_avg_intact_same);
        [bck_abs_intact_opposite, bck_abs_avg_intact_opposite] = zeroPadding(bck_abs_intact_opposite, bck_abs_avg_intact_opposite);
        [bck_abs_same, bck_abs_avg_same] = zeroPadding(bck_abs_same, bck_abs_avg_same);
        [bck_abs_opposite, bck_abs_avg_opposite] = zeroPadding(bck_abs_opposite, bck_abs_avg_opposite);
        tar_abs_avg = tar_abs_avg + tar_abs;
        tar_abs_avg_intact = tar_abs_avg_intact + tar_abs_intact;
        bck_abs_avg_intact_same = bck_abs_avg_intact_same + bck_abs_intact_same;
        bck_abs_avg_intact_opposite = bck_abs_avg_intact_opposite + bck_abs_intact_opposite;
        bck_abs_avg_same = bck_abs_avg_same + bck_abs_same;
        bck_abs_avg_opposite = bck_abs_avg_opposite + bck_abs_opposite;
    end
end

tar_abs_avg = tar_abs_avg/num_target;
tar_abs_avg_intact = tar_abs_avg_intact/num_target;
bck_abs_avg_intact_same = bck_abs_avg_intact_same/num_target;
bck_abs_avg_same = bck_abs_avg_same/num_target;
bck_abs_avg_intact_opposite = bck_abs_avg_intact_opposite/num_target;
bck_abs_avg_opposite = bck_abs_avg_opposite/num_target;

[tar_abs_avg, tar_abs_avg_intact] = zeroPadding(tar_abs_avg, tar_abs_avg_intact);
[bck_abs_avg_intact_same, bck_abs_avg_same] = zeroPadding(bck_abs_avg_intact_same, bck_abs_avg_same);
[bck_abs_avg_intact_opposite, bck_abs_avg_opposite] = zeroPadding(bck_abs_avg_intact_opposite, bck_abs_avg_opposite);

tar_abs_avg_sum = (tar_abs_avg + tar_abs_avg_intact)/2;
bck_abs_avg_same_sum = (bck_abs_avg_intact_same + bck_abs_avg_same)/2;
bck_abs_avg_opposite_sum = (bck_abs_avg_intact_opposite + bck_abs_avg_opposite)/2;
[bck_abs_avg_same_sum, bck_abs_avg_opposite_sum] = zeroPadding(bck_abs_avg_same_sum, bck_abs_avg_opposite_sum);
bck_abs_avg_sum = (bck_abs_avg_same_sum + bck_abs_avg_opposite_sum)/2;

[tar_abs_avg_sum, bck_abs_avg_sum] = zeroPadding(tar_abs_avg_sum, bck_abs_avg_sum);
gain = tar_abs_avg_sum./bck_abs_avg_sum;

% generation of fitler parameter according to the gain
f = (0:(numel(gain) - 1))*fs/numel(gain);
f_half = f(f< fs/2);
f_half = f_half';
gain_half = gain(f<fs/2);
b = fir2(8, f_half/max(f_half), gain_half); % smaller the filter order, smoother the filter
end

