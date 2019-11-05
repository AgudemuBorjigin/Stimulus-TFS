% mixing target and masker for different configurations
fs = 44100;
rampdur = 0.01;
t_onset = 0.8;
% CHANGE AS NEEDED
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';

configuration = 'sum'; % 'pitch', 'space', 'anechoic', 'echo', 'sum'
flag_c = 1;
while flag_c
    switch configuration
        case 'anechoic'
            SNRs = 4:-2:-6; % dB, change in 'target_masker.m' first
            flag_c = 0;
        case 'pitch'
            SNRs = 10:-2:0; % dB, change in 'target_masker.m' first
            flag_c = 0;
        case 'space'
            SNRs = 8:-2:-2; % dB, change in 'target_masker.m' first
            flag_c = 0;
        case 'echo'
            SNRs = 10:-2:0; % dB, change in 'target_masker.m' first
            flag_c = 0;
        case 'sum'
            SNRs = 2:-2:-8; % dB, change in 'target_masker.m' first
            flag_c = 0;
        otherwise
            fprintf(2, 'Unrecognized configuration type! Try again!\n');
    end
end

N = [10, 10, 10, 10, 10, 10]; 
num_trials = sum(N);
num_snr = numel(SNRs);

gender = 'same_gender';
b_same = filter_param(num_trials, gender, strcat(root_audios, '/target_masker/', gender, '/'), fs);
gender = 'opposite_gender';
b_opposite = filter_param(num_trials, gender, strcat(root_audios, '/target_masker/', gender, '/'), fs);

if strcmp(configuration,'anechoic')
    num_trial = 0;
    rand_trialnums = randperm(sum(N));
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_same, b_same, configuration, SNRs(i),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'pitch')
    num_trial = 0;
    rand_trialnums = randperm(sum(N));
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_opposite, b_opposite, configuration, SNRs(i), int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'space')
    num_trial = 0;
    rand_trialnums = randperm(sum(N));
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_same, b_same, configuration, SNRs(i),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'echo')
    num_trial = 0;
    rand_trialnums = randperm(sum(N));
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_same, b_same, configuration, SNRs(i),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'sum')
    num_trial = 0;
    rand_trialnums = randperm(sum(N));
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_opposite, b_opposite, configuration, SNRs(i), int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios);
        end
    end
end

% % ordered snrs for each repetition
% SNRcounts = zeros(nconds, 1);
% SNRlist = [];
% for rep = 1:max(N)
%     for k = 1:nconds
%         if SNRcounts(k) <= N(k)
%             SNRlist = [SNRlist, SNRs(k)]; %#ok<AGROW>
%             SNRcounts(k) = SNRcounts(k) + 1;
%         end
%     end
% end