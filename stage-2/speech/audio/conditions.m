% mixing target and masker for different configurations
configuration = 'ref';
fs = 44100;
rampdur = 0.01;
% CHANGE AS NEEDED
SNRs = 10:-3:-5; % dB, change in 'target_masker.m' first
N = [50, 50, 50, 50, 50, 50]; 
num_snr = numel(SNRs);
totaltrials = sum(N);

root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';

if strcmp(configuration,'ref')
    num_trial = 0;
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_same, configuration, SNRs(i),  int2str(num_trial), target, wordlist, 1, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'pitch')
    num_trial = 0;
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
            load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
            mixture(stim_tar, stim_opposite, configuration, SNRs(i), int2str(num_trial), target, wordlist, 1, fs, rampdur, root_audios);
        end
    end
elseif strcmp(configuration, 'space')
    num_trial = 0;
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
        end
    end
elseif strcmp(configuration, 'echo')
    num_trial = 0;
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
        end
    end
elseif strcmp(configuration, 'sum')
    num_trial = 0;
    for i = 1:num_snr
        for j = 1:N(i)
            num_trial = num_trial + 1;
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