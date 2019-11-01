function [respList, ILDList, thresh] = ...
    getThreshILD3down1up(sID,fc, blockNum, nBlocks, rightOrLeft,useTDT,...
    screenDist, screenWidth,buttonBox)

%% Data storage directory
paraDir = 'C:\Experiments\Agudemu\stimulus-TFS\stage-2\peripheral\ILD\';
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\subjResponses\',sID),'dir'))
    mkdir(strcat(paraDir,'\subjResponses\',sID));
end
respDir = strcat(paraDir,'\subjResponses\',sID,'\');

%% Variable initialization 
feedback = 1; 
feedbackDuration = 0.2;
 
step = 2; % initial step size

FsampTDT = 3; % 100 KHz
useTrigs = 0;
PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT); %,whichScreen); AB

%%
try
    fs = 48828.125; % CHANGE AS NEEDED
    dur = 0.4;
    ramp = 0.02; % gating with 20-ms raised-cosine ramps
    L = 70; % reference level
    ILD = 20; % starting ILD value in dB
    
    if(useTDT)
        %Clearing I/O memory buffers: AB
        invoke(PS.RP,'ZeroTag','datainL');
        invoke(PS.RP,'ZeroTag','datainR');
    end
    %% to show information about the current repetition on screen to the subject, 
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
    ILDList = [];
    trialCount = 0;
    correctCount = 0;
    reps = 0;
    while(~converged)
        % ILDs with different directions in two itervals (pure tone)
        
        renderVisFrame(PS,'FIX'); 
        Screen('Flip',PS.window);
        
        trialCount = trialCount + 1;
        if(trialCount == 1)
            WaitSecs(4);
        else
            WaitSecs(0.5);
        end
        
        t = 0:(1/fs):(dur - 1/fs);
        sig = sin(2*pi*fc*t);
        scale = rms(sig);
        sig = scaleSound(sig);
        sig = rampsound(sig, fs, ramp);
        y = sig;
        
        %% AB
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear Up buffers for 1st stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        sens = phoneSens_ER2(fc); % in dB SPL / 0 dBV (frequency specific)
        % Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
        % to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
        % SPL for pure tones occupying full range in MATLAB. To get a level
        % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. This
        % is for a tone which would have an rms of 0.95/sqrt(2).
        % For a different waveform of rms 'scale', we should adjust further
        % by db(scale*sqrt(2)/0.95).
        
        digDrop = 0; % How much to drop digitally
        wavedata = y * db2mag(-1 * digDrop); % signal remains the same when digDrop = 0
        
        %Start dropping from maximum RMS (actual RMS not peak-equivalent)
        if rightOrLeft(trialCount) == 1
            % correct answer is 1
            drop_left = sens + 10.5236 - (L-ILD/2) - digDrop + db(scale*sqrt(2)/0.95);
            drop_right = sens + 10.5236 - (L+ILD/2) - digDrop + db(scale*sqrt(2)/0.95);
            answer = 1;
        else
            % correct answer is 2
            drop_left = sens + 10.5236 - (L+ILD/2) - digDrop + db(scale*sqrt(2)/0.95);
            drop_right = sens + 10.5236 - (L-ILD/2) - digDrop + db(scale*sqrt(2)/0.95);
            answer = 2;
        end
        %-----------------------------------------
        % Attenuate both sides, just in case
        invoke(PS.RP, 'SetTagVal', 'attA', drop_left);
        invoke(PS.RP, 'SetTagVal', 'attB', drop_right);
        
        
        % The trial flow:
        if useTDT
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata); %AB: looks like left and right channels
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata);
            WaitSecs(0.1);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
        else
            sound(y,fs);
        end
        
        WaitSecs(0.2+dur);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Setup 2nd stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Attenuate both sides, just in case
        invoke(PS.RP, 'SetTagVal', 'attA', drop_right);
        invoke(PS.RP, 'SetTagVal', 'attB', drop_left);
        %-----------------------------------------
        
        if useTDT
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata);
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata);
            WaitSecs(0.1);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
        else
            sound(y,fs);
        end
        
        WaitSecs(0.5+dur);
        
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
            respList = [respList, 1]; %#ok<AGROW>
            correct = 1;
            ILDList = [ILDList, ILD];  %#ok<AGROW>
        else
            fprintf(1,'..which is Wrong!\n');
            respList = [respList, 0]; %#ok<AGROW>
            correct = 0;
            ILDList = [ILDList, ILD];  %#ok<AGROW>
        end
        

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
   
        if trialCount >=3
            if respList(trialCount)
                if (respList(trialCount-1) && respList(trialCount-2)) && (reps == 2)
                    ILD = ILD - step;
                    reps = 0;
                else
                    reps = reps + 1;
                end
            else
                ILD = ILD + step;
                reps = 0;
            end
        else
            if respList(trialCount)
                reps = reps + 1;
            else
                ILD = ILD + step;
                reps = 0;
            end
        end
        
        Screen('Flip',PS.window);
        WaitSecs(feedbackDuration + rand*0.1);
        
        % Counting Reversals
        changes = [0, sign(diff(ILDList))];
        revList = [];
        nonzero = find(abs(changes));

        for k = 2:numel(nonzero)
            if changes(nonzero(k)) ~= changes(nonzero(k-1))
                revList = [revList, nonzero(k)]; %#ok<AGROW>
            end
        end
        nReversals = numel(revList);
                

        if nReversals == 1
            step = 1;
        elseif nReversals == 2
            step = 1;
        elseif nReversals >= 3
            step = 0.5;
        else
        end
        
        
        if nReversals >= 11
            converged = 1;
        else
            converged = 0;
        end
        
    end
    
    % thresh = geomean(ILDList(revList((end-7):end)));
    thresh = median(ILDList(upList)) * 0.25 + 0.75 * median(ILDList(downList)); %#ok<*AGROW>
    
    
    fprintf(2,'\n###### THRESHOLD FOR THIS BLOCK IS %f\n',thresh);
    toc(tstart);
    
    % Save respList
    datetag = datestr(clock);
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,'-')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname_resp = strcat(respDir,sID,'_',num2str(fc),...
        'Hz_', datetag,'.mat');
    save(fname_resp,'ILDList','respList','thresh','fc', 'revList');
    
    
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
        save(fname_resp,'ITDList','respList','fc');
    end
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    % To see error description.
    rethrow(me);
end

