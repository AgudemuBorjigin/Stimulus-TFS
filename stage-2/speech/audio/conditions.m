% mixing target and masker for different configurations
fs_sys = 48828;
rampdur = 0.02;
t_onset = 0.7;
% CHANGE AS NEEDED
os = 'Mac'; % shift betrween Mac and Ubuntu
if strcmp(os, 'Mac')
    root_audios = '/Users/Agudemu/Dropbox/Lab_SNAP/Experiment/speech_audiofiles_stage2';
elseif strcmp(os, 'Ubuntu')
    root_audios = '/home/agudemu/Experiment/speechAudioFiles_stage2';
end

% conds = {'target'};
% SNRs = {12};
% Ns = {20};
conds = {'ref',...
    'noise', 'echo-noise',...
    'echo-pitch', 'echo-space', 'echo-sum', 'echo',...
    'pitch', 'space', 'sum', 'anechoic'};

% SNRs = {10, 10, 10, 14, 14, 14, 14, 12, 12, 12, 12};
% Ns = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2};
SNRs = {10:-6:-14, ...
        14:-8:-18, 14:-9:-22, ...
        18:-8:-14, 18:-7:-10, 18:-8:-14, 18:-6:-6, ...
        14:-7:-14, 16:-8:-16, 14:-8:-18, 14:-7:-14};
Ns = {[4, 4, 4, 4, 4],...
      [4, 4, 4, 4, 4], [4, 4, 4, 4, 4],...
      [4, 4, 4, 4, 4], [4, 4, 4, 4, 4], [4, 4, 4, 4, 4], [4, 4, 4, 4, 4], ...
      [4, 4, 4, 4, 4], [4, 4, 4, 4, 4], [4, 4, 4, 4, 4], [4, 4, 4, 4, 4]};

num_total = 0;
for i = 1:numel(Ns)
    num_total = num_total + sum(Ns{i});
end

num_visits = 1; 
numPerVisit = num_total/num_visits;

b = target_masker(num_total, fs_sys, root_audios);

for v = 1:num_visits
    num_trial = 0;
    rand_trialnums = randperm(numPerVisit);
    for i = 1:numel(conds)
        % basics: config, snr, numTrials per snr
        configuration = conds{i};
        snrs = SNRs{i};
        ns = Ns{i}/num_visits;
        for j = 1:numel(snrs)
            for k = 1:ns(j)
                num_trial = num_trial + 1;
                switch configuration
                    case {'echo-pitch', 'echo-sum', 'pitch', 'sum'}
                        load(strcat(root_audios, '/target_masker/opposite_gender/trial', int2str(num_trial), '.mat'));
                        stim_bck = stim_opposite; 
                    case {'echo', 'echo-space', 'anechoic', 'space', 'echo-noise', 'noise', 'target'}
                        load(strcat(root_audios, '/target_masker/same_gender/trial', int2str(num_trial), '.mat'));
                        stim_bck = stim_same;
                    case {'ref'}
                        load(strcat(root_audios, '/target_masker/intact_same_gender/trial', int2str(num_trial), '.mat'));
                        stim_bck = stim_intact_same; 
                end
                if contains(configuration, 'ref')
                    stim_tar = stim_tar_intact;
                else
                    stim_tar = stim_tar_vocoded;
                end
                mixture(stim_tar, stim_bck, b, configuration, snrs(j),  int2str(rand_trialnums(num_trial)), target, wordlist, t_onset, fs_sys, rampdur, root_audios, v);
                %% for keeping track of stimulus config information
                info{rand_trialnums(num_trial), 3} = configuration; %#ok<SAGROW>
                info{rand_trialnums(num_trial), 2} = snrs(j); %#ok<SAGROW>
                info{rand_trialnums(num_trial), 1} = target; %#ok<SAGROW>
                info{rand_trialnums(num_trial), 4} = tar_speaker; %#ok<SAGROW>
            end
        end
    end
    fid = fopen(strcat(root_audios, '/mixture/', 'visit-', num2str(v), '/stimulus_ref.xls'),'wt');
    for i = 1:num_trial
        fprintf(fid,'%d,%s, %s,%s\n',info{i,1}, info{i,2}, info{i,3}, info{i,4});
    end
    fclose(fid);
end