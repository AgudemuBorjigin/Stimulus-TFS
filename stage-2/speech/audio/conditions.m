% mixing target and masker for different configurations
fs_sys = 48828;
rampdur = 0.01;
t_onset = 0.7;
% CHANGE AS NEEDED
root_audios = '/Users/Agudemu/Desktop/Lab/Experiment/speechAudiofiles_stage2';

conds = {'echo-pitch', 'echo-space', 'echo', 'echo-sum', 'pitch', 'space', 'anechoic', 'sum'};
SNRs = {15:-6:-21, 15:-6:-21, 15:-6:-21, 12:-6:-24, 8:-5:-22, 8:-5:-22, 8:-5:-22, 8:-5:-22};
% make sure every number is divisible by 4 
Ns = {[24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24],...
       [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24],...
       [24, 36, 36, 36, 36, 36, 24], [24, 36, 36, 36, 36, 36, 24]};

%conds = {'pitch', 'anechoic'};
%SNRs = {-6, -6};
%Ns = {10, 10};

num_total = 0;

for i = 1:numel(Ns)
    num_total = num_total + sum(Ns{i});
end

num_visits = 4;
numPerVisit = num_total/num_visits;
for v = 1:num_visits
    count = 0;
    num_trial = 0;
    rand_trialnums = randperm(numPerVisit);
    for i = 1:numel(conds)
        configuration = conds{i};
        snrs = SNRs{i};
        ns = Ns{i}/num_visits;
        target_masker(sum(ns), count, fs_sys, root_audios);
        gender = 'same_gender';
        b_same = filter_param(sum(ns), count, gender, strcat(root_audios, '/target_masker/', gender, '/'));
        gender = 'opposite_gender';
        b_opposite = filter_param(sum(ns), count, gender, strcat(root_audios, '/target_masker/', gender, '/'));
        
        for j = 1:numel(snrs)
            for k = 1:ns(j)
                num_trial = num_trial + 1;
                switch configuration
                    case {'echo-pitch', 'echo-sum', 'pitch', 'sum'}
                        load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
                        stim_bck = stim_opposite; b = b_opposite;
                    otherwise
                        load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
                        stim_bck = stim_same; b = b_same;
                end
                mixture(stim_tar, stim_bck, b, configuration, snrs(j),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs_sys, rampdur, root_audios, v);
                info{rand_trialnums(num_trial), 3} = configuration; %#ok<SAGROW>
                info{rand_trialnums(num_trial), 2} = snrs(j); %#ok<SAGROW>
                info{rand_trialnums(num_trial), 1} = target; %#ok<SAGROW>
                info{rand_trialnums(num_trial), 4} = tar_gender; %#ok<SAGROW>
            end
        end
        count = sum(ns) + count;
    end
    fid = fopen(strcat(root_audios, '/mixture/', 'visit-', num2str(v), '/stimulus-ref.xls'),'wt');
    for i = 1:num_trial
        fprintf(fid,'%d,%s,%s\n',info{i,1}, info{i,3}, info{i,4});
    end
    fclose(fid);
end