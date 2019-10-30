% CHANGE THE MAT FILE AS NEEDED ACCORDING TO nBlocks, nPerBlock
load('type.mat', 'nBlocks', 'nPerBlock', 'Types', 'nRep', 'nRepNonTar');
ITD = 300e-6;

buttonBox = 1;
earPhone = 1;

subj = input('Please enter subject ID:', 's');
sID = strcat(subj);

% Data storage directory
paraDir = 'C:\AgudemuCode\Stimulus\Attention\';
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\subjResponses\',sID),'dir'))
    mkdir(strcat(paraDir,'\subjResponses\',sID));
end
respDir = strcat(paraDir,'\subjResponses\',sID,'\');

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
useTrigs = 0;
FsampTDT = 3; % 48828.125 Hz
fs = 48828.125;
feedback = 1; 
feedbackDuration = 0.2; 


PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT); %,whichScreen); AB

for k = 1:nBlocks    
    % AB: to show information about the current repetition on screen to the subject,
    % and to get the subject's response to proceed the task
    textlocH = PS.rect(3)/4;
    textlocV = PS.rect(4)/3;
    line2line = 50;
    blockNumStr = num2str(k);
    totalBlocks = num2str(nBlocks);
    info1 = strcat('This is block #',blockNumStr,'/',totalBlocks,'...\n');
    info2 = strcat('Press any button twice to begin...');
    info = strcat(info1, info2);
    DrawFormattedText(PS.window,info,'center', 'center',PS.white);
    Screen('Flip',PS.window);
    
    if buttonBox
        getResponse(PS.RP);
        getResponse(PS.RP);
    else
        getResponseKb;
        getResponseKb;
    end
    
    invoke(PS.RP, 'SetTagVal', 'trgname', 253); %Start saving EEG
    WaitSecs(0.1);
    invoke(PS.RP, 'SoftTrg', 6); %send trigger
    WaitSecs(3);
    
    % get response from attention task
    answerList = zeros(1, nPerBlock);
    for i = 1:nPerBlock
        typeStr = dec2bin(Types((k-1)*nPerBlock + i), 3);
        % 3 binary digits to determine attenDir, streamType, pitchType
        
        attenDir = str2double(typeStr(1));
        streamType = str2double(typeStr(2));
        pitchType = str2double(typeStr(3));
        nRep_current = nRep((k-1)*nPerBlock+i);
        nRepNonTar_current = nRepNonTar((k-1)*nPerBlock+i);
        
        % ----- Run Trial Script ---- 
        getAttended; %Script in a separate file
        %----------------------------
        answerList(i) = correct;
    end
    
    % Display end of block
    info1 = strcat('Done with Block #',blockNumStr,'/',totalBlocks, '\n');
    info2 = strcat('Press any button to continue...');
    info = strcat(info1, info2);
    DrawFormattedText(PS.window,info,'center','center',PS.white);
    Screen('Flip',PS.window);
    if buttonBox
        getResponse(PS.RP);
    else
        getResponseKb;
    end
    
    datetag = datestr(clock);
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,'-')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname_resp = strcat(respDir,sID,'_', datetag,'.mat');
    save(fname_resp, 'answerList');
    
    WaitSecs(3);
    invoke(PS.RP, 'SetTagVal', 'trgname', 254); %Stop saving EEG
    WaitSecs(0.1);
    invoke(PS.RP, 'SoftTrg', 6); %send trigger
    WaitSecs(0.1);
end

sca;
close_play_circuit(PS.f1,PS.RP); % AB

