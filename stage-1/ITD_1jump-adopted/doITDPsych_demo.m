% Note: before running this script, run randIPDsTrigNums.m first if
% variables such as randTrigNums and randIPDs are not in the workplace
load('randITDsTrigNums_demo.mat');

TFSorENV = 'TFS'; % Determines if the phase jump is in TFS or ENV
fc = 500;
fm = 40.8;
dur = 1.5;
ramp = 0.005;

useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;
FsampTDT = 3; % 48828.125 Hz
useTrigs = 0;

subj = input('Please enter subject ID:', 's');
sID = strcat(subj, '_','BothEar');

paraDir = 'C:\AgudemuCode\Stimulus\ITD_1jump\';
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\subjResponsesPsych\',sID),'dir'))
    mkdir(strcat(paraDir,'\subjResponsesPsych\',sID));
end
respDir = strcat(paraDir,'\subjResponsesPsych\',sID,'\');

% some parameter initailizations for the loop
correct = zeros(1,numel(randITDs));
nBlocks = 1;
nPerBlock = numel(randITDs)/nBlocks;
for k = 1:nBlocks
    
    PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT); %,whichScreen);
    
    textlocH = PS.rect(3)/4;
    textlocV = PS.rect(4)/3;
    line2line = 50;
    BlockNumStr = num2str(k);
    nBlockStr = num2str(nBlocks);
    info = strcat('This is block #',BlockNumStr,'/ Block',nBlockStr,'...');
    Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
    info = strcat('Press any button twice to begin...');
    Screen('DrawText',PS.window,info,textlocH,textlocV+line2line,PS.white);
    Screen('Flip',PS.window);
    
    % START SAVING EEG, if behavior and EEG are simultaneous
    invoke(PS.RP, 'SetTagVal', 'trgname', 253);
    invoke(PS.RP, 'SoftTrg', 6);
    
    if buttonBox
        getResponse(PS.RP);
        getResponse(PS.RP);
    else
        getResponseKb; %#ok<UNRCH>
        getResponseKb;
    end
    
    tstart = tic;
    for p = ((k-1)*nPerBlock + 1): k*nPerBlock
        
        correct(p) = getCorrectITD(leftOrRight{p}, TFSorENV, sID, fc, fm, randITDs(p), dur, ramp, randTrigNums(p), p,...
            k, useTDT,buttonBox, PS);
    end
    toc(tstart);
    
    % STOP SAVING EEG, if behavior and EEG are simultaneous
    invoke(PS.RP, 'SetTagVal', 'trgname', 254);
    invoke(PS.RP, 'SoftTrg', 6);
    
    sca;
    close_play_circuit(PS.f1,PS.RP);
    
    datetag = datestr(clock);
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,'-')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname_resp = strcat(respDir,sID,'_',TFSorENV, '_', datetag,'.mat');
    presentedITDs = randITDs(((k-1)*nPerBlock + 1): k*nPerBlock);
    save(fname_resp,'fc','presentedITDs','correct', 'k');
end

