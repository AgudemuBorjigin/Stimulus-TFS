function b = target_masker(totaltrials, fs, root_audios)
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
speakers_masker_f = {'NCF011', 'NCF015', 'PNF139', 'PNF142'};
speakers_masker_m = {'NCM012', 'NCM017', 'PNM078', 'PNM086'};
audiofiles_f = cell(1, numel(speakers_masker_f));
audiofiles_m = cell(1, numel(speakers_masker_m));
for n = 1:numel(speakers_masker_f)
    audiofiles_f{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_f{n}, '/audio/*.wav'));
    audiofiles_m{n} = dir(strcat(root_audios, '/harvard_sentences/', speakers_masker_m{n}, '/audio/*.wav'));
end

num_interferer = numel(speakers_masker_f);

nfilts = 16; 
f_low = 80;
f_high = 16000;

% to make the masker unintelligeble, nfilts number of senstences from a speaker are chosen as inputs
% to nfilts number of filter bands, outputs of which are then mixed to
% generate one masker
for n = 1:num_target
    if contains(speakers_target{n}, 'F')
        for j = 1:num_interferer
            audio_names_same{n, j} = rand_elements({audiofiles_f{j}.name}, nfilts); %#ok<AGROW>
            audio_names_opposite{n, j} = rand_elements({audiofiles_m{j}.name}, nfilts); %#ok<AGROW>
            audio_names_intact_same{n, j} = rand_elements({audiofiles_f{j}.name}, 1); %#ok<AGROW>
            audio_names_intact_opposite{n, j} = rand_elements({audiofiles_m{j}.name}, 1); %#ok<AGROW>
        end
    elseif contains(speakers_target{n}, 'M')
        for j = 1:num_interferer
            audio_names_opposite{n, j} = rand_elements({audiofiles_f{j}.name}, nfilts);
            audio_names_same{n, j} = rand_elements({audiofiles_m{j}.name}, nfilts);
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
    fname_tar = fileDir(root_audios, speakers_target{i}, wordlist, target);
    if contains(speakers_target{i}, 'F')
        gender = 'F';
    else
        gender = 'M';
    end
    [stim_tar_vocoded, stim_tar_intact] = sig_vocode(fname_tar, fs, f_low, f_high, root_audios, gender, 0, nfilts);
    tar_speaker = speakers_target{i};
    % masker audio
    % mixing audio signals to generate masker
    if contains(tar_speaker, 'F')
        gender_same = 'F';
        gender_opposite = 'M';
    else
        gender_same = 'M';
        gender_opposite = 'F';
    end
    for j = 1:num_interferer
        [~, stim_intact_same_temp] = sig_vocode(audio_names_intact_same{i, j}, fs, f_low, f_high, root_audios, gender_same, 1, nfilts);
        [~, stim_intact_opposite_temp] = sig_vocode(audio_names_intact_opposite{i, j}, fs, f_low, f_high, root_audios, gender_opposite, 1, nfilts);
        [stim_same_temp, ~] = sig_vocode(audio_names_same{i, j}, fs, f_low, f_high, root_audios, gender_same, 1, nfilts);
        [stim_opposite_temp, ~] = sig_vocode(audio_names_opposite{i, j}, fs, f_low, f_high, root_audios, gender_opposite, 1, nfilts);
        if j == 1
            stim_same = stim_same_temp;
            stim_opposite = stim_opposite_temp;
            stim_intact_same = stim_intact_same_temp;
            stim_intact_opposite = stim_intact_opposite_temp;
        else
            [stim_same_temp, stim_same] = centering(stim_same_temp, stim_same);
            [stim_opposite_temp, stim_opposite] = centering(stim_opposite_temp, stim_opposite);
            [stim_intact_same_temp, stim_intact_same] = centering(stim_intact_same_temp, stim_intact_same);
            [stim_intact_opposite_temp, stim_intact_opposite] = centering(stim_intact_opposite_temp, stim_intact_opposite);
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
    save(savename, 'stim_tar_vocoded', 'stim_same', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_vocoded', 'stim_opposite', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/intact_same_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_intact', 'stim_intact_same', 'target', 'wordlist', 'tar_speaker', 'fs');
    savename = [root_audios, '/target_masker/intact_opposite_gender/trial', num2str(i), '.mat'];
    save(savename, 'stim_tar_intact', 'stim_intact_opposite', 'target', 'wordlist', 'tar_speaker', 'fs');
    
    % taking avg spectrum
    tar_abs = abs(fft(stim_tar_vocoded));
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
        [tar_abs, tar_abs_avg] = centering(tar_abs, tar_abs_avg);
        [tar_abs_intact, tar_abs_avg_intact] = centering(tar_abs_intact, tar_abs_avg_intact);
        [bck_abs_intact_same, bck_abs_avg_intact_same] = centering(bck_abs_intact_same, bck_abs_avg_intact_same);
        [bck_abs_intact_opposite, bck_abs_avg_intact_opposite] = centering(bck_abs_intact_opposite, bck_abs_avg_intact_opposite);
        [bck_abs_same, bck_abs_avg_same] = centering(bck_abs_same, bck_abs_avg_same);
        [bck_abs_opposite, bck_abs_avg_opposite] = centering(bck_abs_opposite, bck_abs_avg_opposite);
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

[tar_abs_avg, tar_abs_avg_intact] = centering(tar_abs_avg, tar_abs_avg_intact);
[bck_abs_avg_intact_same, bck_abs_avg_same] = centering(bck_abs_avg_intact_same, bck_abs_avg_same);
[bck_abs_avg_intact_opposite, bck_abs_avg_opposite] = centering(bck_abs_avg_intact_opposite, bck_abs_avg_opposite);

tar_abs_avg_sum = (tar_abs_avg + tar_abs_avg_intact)/2;
bck_abs_avg_same_sum = (bck_abs_avg_intact_same + bck_abs_avg_same)/2;
bck_abs_avg_opposite_sum = (bck_abs_avg_intact_opposite + bck_abs_avg_opposite)/2;
[bck_abs_avg_same_sum, bck_abs_avg_opposite_sum] = centering(bck_abs_avg_same_sum, bck_abs_avg_opposite_sum);
bck_abs_avg_sum = (bck_abs_avg_same_sum + bck_abs_avg_opposite_sum)/2;

[tar_abs_avg_sum, bck_abs_avg_sum] = centering(tar_abs_avg_sum, bck_abs_avg_sum);
gain = tar_abs_avg_sum./bck_abs_avg_sum;

% generation of fitler parameter according to the gain 
f = (0:(numel(gain) - 1))*fs/numel(gain);
f_half = f(f< fs/2);
f_half = f_half';
gain_half = gain(f<fs/2);
b = fir2(8, f_half/max(f_half), gain_half); % smaller the filter order, smoother the filter
end

