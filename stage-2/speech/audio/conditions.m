% mixing target and masker for different configurations
fs = 44100;
rampdur = 0.01;
t_onset = 0.7;
% CHANGE AS NEEDED
root_audios = '/Users/baoagudemu1/Desktop/Lab/Experiment/speechAudiofiles_stage2';

conds = {'echo-pitch', 'echo-space', 'echo', 'echo-sum', 'pitch', 'space', 'anechoic', 'sum'};
SNRs = {15:-5:-15, 15:-5:-15, 15:-5:-15, 15:-5:-15, 8:-5:-22, 8:-5:-22, 8:-5:-22, 8:-5:-22};
% make sure every number is divisible by 4 
Ns = {[24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24],...
      [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24],...
      [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24]};
num_total = 0;

for i = 1:numel(Ns)
    num_total = num_total + sum(Ns{i});
end

target_masker(num_total);
gender = 'same_gender';
b_same = filter_param(num_total, gender, strcat(root_audios, '/target_masker/', gender, '/'), fs);
gender = 'opposite_gender';
b_opposite = filter_param(num_total, gender, strcat(root_audios, '/target_masker/', gender, '/'), fs);

num_visits = 4;
numPerVisit = num_total/num_visits;
for v = 1:num_visits
    num_trial = 0;
    rand_trialnums = randperm(numPerVisit);
    for i = 1:numel(conds)
        configuration = conds{i};
        snrs = SNRs{i};
        ns = Ns{i}/num_visits;
        for j = 1:numel(snrs)
            for k = 1:ns(j)
                num_trial = num_trial + 1;
                switch configuration
                    case {'echo-pitch', 'echo-sum', 'pitch', 'sum'}
                        load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
                        stim = stim_opposite; b = b_opposite;
                    otherwise
                        load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
                        stim = stim_same; b = b_same;
                end
                mixture(stim_tar, stim, b, configuration, snrs(j),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs, rampdur, root_audios, v);
            end
        end
    end
end