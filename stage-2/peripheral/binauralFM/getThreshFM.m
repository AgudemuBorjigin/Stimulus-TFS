function [respList, fdevList, thresh] = ...
    getThreshFM(sID,fc, blockNum, nBlocks,useTDT,...
    screenDist, screenWidth,buttonBox)
%% Data storage directory
paraDir = 'C:\Experiments\Agudemu\stimulus-TFS\stage-2\peripheral\binauralFM\';
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\subjResponses\',sID),'dir'))
    mkdir(strcat(paraDir,'\subjResponses\',sID));
end
respDir = strcat(paraDir,'\subjResponses\',sID,'\');

%% Variable initialization 
feedback = 1;
feedbackDuration = 0.2;

Nup = 3; % Weighted 1-up-1down with weights of 3:1
NmaxTrials = 80;
NminTrials = 20;
target = (randperm(NmaxTrials) > NmaxTrials/2); % randomizing target (containing FM) 
dev_dir = [ones(1, NmaxTrials/2), -1*ones(1, NmaxTrials/2)];
dev_dir = dev_dir(randperm(NmaxTrials)); % randomizing target (containing FM) 

FsampTDT = 3; % 48828.125 Hz
useTrigs = 0;
PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT); %,whichScreen); AB

%%
try
    fs = 48828.125;
    dur = 0.5;   
    fm = 2; 
    ramp = 0.025; % gating with 25-ms raised-cosine ramps
    L = 70; % fixed value at 70 dB SPL
    fdev = 16; % starting frequency deviation value, big enough to make sure the subject understands the task
    stepDown = db2mag(-4); % AB: stepDown from initail fdev 
    stepUp = db2mag(-stepDown)*Nup;
    
    if(useTDT)
        %Clearing I/O memory buffers: AB
        invoke(PS.RP,'ZeroTag','datainL');
        invoke(PS.RP,'ZeroTag','datainR');
    end
    %% AB: to show information about the current repetition on screen to the subject
    % and to get the subject's response to proceed the task
    textlocH = PS.rect(3)/4;
    textlocV = PS.rect(4)/3;
    line2line = 50;
    blockNumStr = num2str(blockNum);
    totalBlocks = num2str(nBlocks);
    info = strcat('This is block #',blockNumStr,'/',totalBlocks,'...');
    Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
    info = strcat('Press any button twice to begin...');
    Screen('DrawText',PS.window,info,textlocH,textlocV+line2line,PS.white);
    Screen('Flip',PS.window);
    
    if buttonBox
        getResponse(PS.RP);
        getResponse(PS.RP);
    else
        getResponseKb;
        getResponseKb;
    end
    
    %% Starting the task
    tstart = tic;
    
    converged = 0; % flag to determine when to stop getting threshold
    respList = [];
    fdevList = [];
    trialCount = 0;
    correctCount = 0;
    
    while(~converged)
        % target (FM) and dummy non-target (pure tone)
        renderVisFrame(PS,'FIX');
        Screen('Flip',PS.window);
        
        trialCount = trialCount + 1;
        if(trialCount == 1)
            WaitSecs(4);
        else
            WaitSecs(0.5);
        end
        
        dummy = makeFMstim_tones(0, fc, fs, fm, dur, ramp);
        sig_pos_dev = makeFMstim_binaural(dev_dir(trialCount), fdev, fc, fs, fm,...
                dur, ramp);
        sig_neg_dev = makeFMstim_binaural(-1 * dev_dir(trialCount), fdev, fc, fs, fm,...
                dur, ramp);
        % AB: randomizing the order of playing FM and pure tones
        if(target(trialCount))
            % Correct answer is "1"
            answer = 1;
            y_left = sig_pos_dev;
            y_right = sig_neg_dev;
            z_left = dummy;
            z_right = dummy;
        else
            % Correct answer is "2"
            answer = 2;
            z_left = sig_pos_dev;
            z_right = sig_neg_dev;
            y_left = dummy;
            y_right = dummy;
        end
        scale = (rms(sig_pos_dev) + rms(dummy))/2;
        y = [y_left; y_right];
        z = [z_left; z_right];
        
        %% AB
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear Up buffers for 1st stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        sens = phoneSens(fc); % in dB SPL / 0 dBV (frequency specific)
        % Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
        % to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
        % SPL for pure tones occupying full range in MATLAB. To get a level
        % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. This
        % is for a tone which would have an rms of 0.95/sqrt(2).
        % For a different waveform of rms 'scale', we should adjust further
        % by db(scale*sqrt(2)/0.95).
        
        digDrop = 0; % How much to drop digitally
        drop = sens + 10.5236 - L - digDrop + db(scale*sqrt(2)/0.95);
        % Start dropping from maximum RMS (actual RMS not peak-equivalent)
        wavedata = y * db2mag(-1 * digDrop); % AB: signal remains the same when digDrop = 0
        %-----------------------------------------
        % Attenuate both sides, just in case
        invoke(PS.RP, 'SetTagVal', 'attA', drop);
        invoke(PS.RP, 'SetTagVal', 'attB', drop);
        
        
        % The trial flow:
        if useTDT
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :)); %AB: looks like left and right channels
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
            WaitSecs(0.1);
            %Start playing from the buffer:
            Screen('DrawText',PS.window,'1',PS.rect(3)/2 - 20,PS.rect(4)/2-20,PS.white);
            Screen('Flip',PS.window);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
        else
            sound(y,fs);
        end
        
        WaitSecs(1.4); % should consider stimulus duration 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Setup 2nd stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        digDrop = 0;
        drop = sens + 10.5236 - L - digDrop + db(scale*sqrt(2)/0.95);
        %Start dropping from maximum RMS (actual RMS not peak-equivalent)
        wavedata = z * db2mag(-1 * digDrop);
        % Attenuate both sides, just in case
        invoke(PS.RP, 'SetTagVal', 'attA', drop);
        invoke(PS.RP, 'SetTagVal', 'attB', drop);
        %-----------------------------------------
        
        if useTDT
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
            WaitSecs(0.1);
            %Start playing from the buffer:
            Screen('DrawText',PS.window,'2',PS.rect(3)/2-20,PS.rect(4)/2-20,PS.white);
            Screen('Flip',PS.window);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
        else
            sound(z,fs);
        end
        
        WaitSecs(1); % should consider stimulus duration 
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Response Frame
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        renderVisFrame(PS,'RESP');
        Screen('Flip',PS.window);
        if(buttonBox)
            resp = getResponse(PS.RP);
        else
            resp = getResponseKb;
        end
        
        fprintf(1,'\n Target = %s, Response = %s',num2str(answer),num2str(resp));
        if((numel(resp)>=1) && ((answer - resp(end)) == 0))
            fprintf(1,'..which is correct!\n');
            respList = [respList, 1];
            correct = 1;
            fdevList = [fdevList, fdev]; 
        else
            fprintf(1,'..which is Wrong!\n');
            respList = [respList, 0];
            correct = 0;
            fdevList = [fdevList, fdev]; 
        end
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Feedback Frame
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if(feedback)
            if(correct)
                renderVisFrame(PS,'GO'); % AB
                correctCount = correctCount +1;
                
            else
                renderVisFrame(PS,'NOGO');
                
            end
        end
        
        if(correct)
            fdev = fdev*stepDown; % AB: changed from m to fdev
        else
            
            fdev = fdev*stepUp; % AB: changed from m to fdev
            
        end
        

        if( fdev < 0)
            fdev = 0;
            % fedv = fdev + stepUp; % not sure if this is necessary
        end
        

        
        Screen('Flip',PS.window);
        WaitSecs(feedbackDuration + rand*0.1);
        
        % Counting Reversals
        revList = [];
        downList = [];
        upList = [];
        nReversals = 0;
        for k = 3:numel(fdevList)
            if((fdevList(k-1) > fdevList(k)) && (fdevList(k-1) > fdevList(k-2)))
                nReversals = nReversals + 1;  revList = [revList, (k-1)];
                downList = [downList, (k-1)];
            end
            if((fdevList(k-1) < fdevList(k)) && (fdevList(k-1) < fdevList(k-2)))
                nReversals = nReversals + 1;  revList = [revList, (k-1)];
                upList = [upList, (k-1)];
            end
        end
        
        if(nReversals >= 4)
            stepDown = db2mag(-2);
            stepUp = Nup*db2mag(-stepDown);
        end
        
        
        if ((nReversals >= 11) && (trialCount > NminTrials)) || ...
                trialCount >= NmaxTrials
            converged = 1;
        else
            converged = 0;
        end
        
    end
    
    thresh = median(fdevList(upList)) * 0.25 + 0.75 * median(fdevList(downList)); %#ok<*AGROW>
    
    
    fprintf(2,'\n###### THRESHOLD FOR THIS BLOCK IS %f\n',thresh);
    toc(tstart);
    
    % Save respList
    datetag = datestr(clock);
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,'-')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname_resp = strcat(respDir,sID,'_',num2str(fc),...
        'Hz_', datetag,'.mat');
    save(fname_resp,'fdevList','respList','thresh','fc');
    
    
    % Display end of block
    info = strcat('Done with Block #',blockNumStr,'/',totalBlocks);
    Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
    
    
    info = strcat('Press any button to continue...');
    
    Screen('DrawText',PS.window,info,textlocH,textlocV + 3*line2line,PS.white);
    Screen('Flip',PS.window);
    if buttonBox
        getResponse(PS.RP);
    else
        getResponseKb;
    end
    
    sca;
    close_play_circuit(PS.f1,PS.RP); % AB
    
catch me%#ok<CTCH>
    
    
    Screen('CloseAll');
    
    % Restores the mouse cursor.
    ShowCursor;
    
    % Save stuff
    crashSave = 1;
    if(crashSave)
        datetag = datestr(clock);
        datetag(strfind(datetag,' ')) = '_';
        datetag(strfind(datetag,'-')) = '_';
        datetag(strfind(datetag,':')) = '_';
        fname_resp = strcat(respDir,sID,'_',num2str(fc),...
            'Hz_crash_',datetag,'.mat');
        save(fname_resp,'fdevList','respList','fc');
    end
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    % To see error description.
    rethrow(me);
end

