function [sig, fs] = generateRawLists(nList, nSNR)
nSNR = nSNR+2; % adding two to consider two reference targets without background

froot = '/home/agudemu/Experiment/OriginalHarvardSpeech'; % CHNAGE AS NEEDED
saveRoot = '/home/agudemu/Experiment/Stimulus/QuickSIN/original_stimuli_harvard'; % CHNAGE AS NEEDED
voiceList = dir(froot); nVoices = numel(voiceList)-2; % 2 extras are not file directories
voicesIndex = 1:nVoices;
% excel file for storing the text content of each target speech
fid = fopen(strcat(saveRoot, '/QuickSinLists.csv'), 'w');% CHANGE AS NEEDED
txtfiles = dir('/home/agudemu/Experiment/transcripts/*.txt'); % CHANGE AS NEEDED

% names of txtFiles are extracted here to search for audio files for target
txtFilesRanArray = txtfiles(1:nList*nSNR);
txtArray = cell(1,nList*nSNR);
for i = 1:nList*nSNR
    txtArray{i} = txtFilesRanArray(i).name;
end
% names of txtFiles are extracted here to search for audio files for
% background babbles
txtFilesRanArrayBg = txtfiles((nList*nSNR+1):((nList*nSNR+1)+(numel(txtfiles)-(nList*nSNR))/2)); % CHANGE AS NEEDED
txtArrayBg = cell(1,numel(txtFilesRanArrayBg));
for i = 1:numel(txtFilesRanArrayBg)
    txtArrayBg{i} = txtFilesRanArrayBg(i).name;
end

txtFilesRanArrayBup = txtfiles(((nList*nSNR+1)+(numel(txtfiles)-(nList*nSNR))/2):end); % CHANGE AS NEEDED
txtArrayBup = cell(1, numel(txtFilesRanArrayBup));
for i = 1:(numel(txtFilesRanArrayBup))
    txtArrayBup{i} = txtFilesRanArrayBup(i).name;
end

iBup = 1;
lenArray = zeros(1, nList*nSNR);
wavNamesTar = cell(1, nList*nSNR);

for i = 1:nList
    fprintf(fid, strcat('List ', num2str(i), '\n'));
    % each speech (target) in the same list is from the same voice
    if i > 33
        i_v = 1;
    else
        i_v = i;
    end
    voiNameTar = voiceList(i_v+2).name;
    wavFiles = dir(strcat(froot, '/', voiNameTar, '/audio/*.wav'));
    wavNamesArray = cell(1,numel(wavFiles));
    for n = 1:numel(wavFiles)
        wavNamesArray{n} = wavFiles(n).name;
    end
    wavNamesArray = unique(wavNamesArray);
    
    voicesIndexBck = voicesIndex(voicesIndex~=i_v); % voices of background are different from target
    iteration = nSNR+1; 
    iterationTxt = 0;
    
    for j = i*nSNR:-1:1+((i-1)*nSNR)
        iteration = iteration-1;
        iterationTxt = iterationTxt + 1;
        
        text = txtArray{j}; text = text(1:find(text == '.'));
        wavNamesTar{j} = strcat(voiNameTar, '_', text, 'wav');
        % to make sure there is a wav file that says the content of the
        % text in that voice
        while (~ismember(wavNamesTar{j},wavNamesArray))
            text = txtArrayBup{iBup}; text = text(1:find(text == '.'));
            wavNamesTar{j} = strcat(voiNameTar, '_', text, 'wav');
            if ismember(wavNamesTar{j},wavNamesArray)
                txtArrayBup{iBup} = 'empty.'; % placing "empty" to pervent the use of the same sentence for following targets
            end
            iBup = iBup+1;
        end     
        fPathTar = strcat(froot, '/', voiNameTar, '/audio/', wavNamesTar{j});
        [target, fs] = audioread(fPathTar);
        % storing the transcript for target
        txtName = strcat(text,'txt');
        fPathTxt = strcat('/home/agudemu/Experiment/transcripts/', txtName); % CHANGE AS NEEDED
        fidTxt = fopen(fPathTxt, 'r');
        sentence = fscanf(fidTxt, '%c');
        fclose(fidTxt);
        fprintf(fid, '%s\n', strcat(num2str(iterationTxt), '. ', sentence));
        
        if j == i*nSNR % CHANGE AS NEEDED, DEPENDING ON THE # OF REFERENCES
            sig = [target, target]; % reference doesn't have background
            sigPath = strcat(saveRoot, '/', 'list', num2str(i), '_reference1.mat'); 
            save(sigPath, 'sig', 'fs');
        elseif j == (i*nSNR -1) % CHANGE AS NEEDED, DEPENDING ON THE # OF REFERENCES
            sig = [target, target]; % reference doesn't have background
            sigPath = strcat(saveRoot, '/', 'list', num2str(i), '_reference2.mat'); 
            save(sigPath, 'sig', 'fs');
        else
            %% background babble
            % background babble consists of 4 other simultaneous different
            % voices, different contents. This combination is different for
            % each target
            maxLen = 0;
            while ((maxLen < length(target))) % make sure the length of background is longer than target
                % using 8 different sentences of different voices to "wrap" the target in between 
                disVoicesIndex = randsample(voicesIndexBck, 8); 
                disVoices = voiceList(disVoicesIndex+2); % two extras are not file directories
                bg = cell(1,8);
                lenBgs = zeros(1,8);
                txtSamples = randsample(txtArrayBg, 8);
                iterationBup_bck = 1;
                for k = 1:numel(disVoices)
                    voiNameBg = disVoices(k).name;    
                    wavFilesBg = dir(strcat(froot, '/', voiNameBg, '/audio/*.wav'));
                    wavNamesArrayBg = cell(1,numel(wavFilesBg));
                    for n = 1:numel(wavFilesBg)
                        wavNamesArrayBg{n} = wavFilesBg(n).name;
                    end
                    text = txtSamples{k}; text = text(1:find(text == '.'));
                    wavNameBg = strcat(voiNameBg, '_', text, 'wav');
                    while (~ismember(wavNameBg,wavNamesArrayBg))
                        text = txtArrayBup{iterationBup_bck}; text = text(1:find(text == '.'));
                        wavNameBg = strcat(voiNameBg, '_', text, 'wav');
                        iterationBup_bck = iterationBup_bck+1;
                    end
                    
                    fPathBg = strcat(froot, '/', voiNameBg,'/audio/', wavNameBg);
                    [bg{k}, fs] = audioread(fPathBg);
                    lenBgs(k) = numel(bg{k});
                end
                maxLen = max(lenBgs);
            end
            
            % mixing different voices as background
            bg2 = cell(1,4);
            lenBgs = zeros(1,4);
            for k = 1:numel(bg)
                bgTemp = bg{k};
                index = find(abs(bgTemp)>0.0001);
                bg{k} = bgTemp(index(1):index(end));
            end
            bg2{1} = [bg{1};bg{2}]; lenBgs(1) = numel(bg2{1});
            bg2{2} = [bg{3};bg{4}]; lenBgs(2) = numel(bg2{2});
            bg2{3} = [bg{5};bg{6}]; lenBgs(3) = numel(bg2{3});
            bg2{4} = [bg{7};bg{8}]; lenBgs(4) = numel(bg2{4});
            maxLen = max(lenBgs);
            lenArray(j) = maxLen;
            for k = 1:numel(bg2)
                bg2{k} = [bg2{k};zeros(maxLen-lenBgs(k),1)];
                level = rms(bg2{k});
                bg2{k} = bg2{k} / level;
                if k >1
                    bg2{1} = bg2{1} + bg2{k}; % mixing 4 sequences together
                end
            end
            background = bg2{1}/4;
            lenDiff = length(background) - length(target);
            if mod(lenDiff,2)
                lenDiffHalf1 = (lenDiff-1)/2 + 1;
                lenDiffHalf2 = (lenDiff-1)/2;
            else
                lenDiffHalf1 = lenDiff/2;
                lenDiffHalf2 = lenDiffHalf1;
            end
            target = [zeros(lenDiffHalf1,1); target; zeros(lenDiffHalf2,1)]; %#ok<AGROW>
            sig = [target,background];
            % change the multiplyer (SNR step) as needed: iteration-2 or
            % iteration -3 (for separated condition)
            sigPath = strcat(saveRoot, '/', 'list', num2str(i), '_snr', num2str((iteration-2)*3), '.mat'); 
            save(sigPath, 'sig', 'fs');
        end
    end
    fprintf(fid, strcat('End', '\n'));
end
fclose(fid);

nSNR = nSNR -2;
maxLen = max(lenArray);

% this part is causing repetition problems: un-unified (without the code below) and unified sound
% files were stored separately, un-unifed sound files don't repeat. 

for listNum = 1:nList
    for i = 1:nSNR 
        fileName = strcat(saveRoot,'/list',num2str(listNum),'_snr',num2str((i-2)*3),'.mat');
        load(fileName, 'sig', 'fs');
        if length(sig(:,1))<maxLen
            tarTmp = [sig(:,1);zeros(maxLen-length(sig(:,1)),1)];
            bckTmp = [sig(:,2);zeros(maxLen-length(sig(:,2)),1)];
            sig = [tarTmp,bckTmp];
        end
        % sig = [tarTmp,bckTmp]; % PUTTING THIS OUTSIDE REPLACES THE SIG WITH MAX LENGTH THE PREVIOUS SIG (if the 'if' statement doesn't execute') !!!
        % fileName = strcat('/home/agudemu/Experiment/Stimulus/QuickSIN/original_stimuli_harvard_sameLength', ...
        %   '/list',num2str(listNum),'_snr',num2str((i-2)*3),'.mat');
        save(fileName, 'sig', 'fs');
    end
end
end