function [respList, Llist, thresh] = ...
    getThresh(sID,fc, blockNum, nBlocks,ear,useTDT,screenDist,...
    screenWidth,buttonBox)

% USAGE:
% [respList, Llist, thresh] = getThresh(sID,fc, blockNum, nBlocks,...
%       ear,useTDT,screenDist,screenWidth,buttonBox)

paraDir = 'C:\AgudemuCode\Stimulus\Screening\';


% whichScreen = 1;
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\subjResponses\',sID),'dir'))
    mkdir(strcat(paraDir,'\subjResponses\',sID));
end
respDir = strcat(paraDir,'\subjResponses\',sID,'\');

FsampTDT = 3; % 48828.125 Hz
useTrigs = 0;
feedback = 1;

feedbackDuration = 0.2;

PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT); %,whichScreen);



Nup = 3; % Weighted 1 up-1down with weights of 3:1


NmaxTrials = 50;
NminTrials = 5;
target = (randperm(NmaxTrials) > NmaxTrials/2);


try
    fs = 48828.125;
    dur = 1.0;
    rampSize = 0.025;
    m = 0.8;
    bw = 50;
    sig = maketranstone(fc,4,m,bw,fs,dur,rampSize);
    dummy = zeros(size(sig));
    if(fc > 10000)
        L = 95;
    else
        L = 70;
    end
    geometric = 0;
    if(geometric)
        stepDown = 0.8;
        stepUp = (1/stepDown)^Nup;
    else
        stepDown = -10;
        stepUp = Nup*(-stepDown);
    end
    
    if(useTDT)
        %Clearing I/O memory buffers:
        invoke(PS.RP,'ZeroTag','datainL');
        invoke(PS.RP,'ZeroTag','datainR');
    end
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
    tstart = tic;
    
    
    converged = 0;
    respList = [];
    Llist = [];
    trialCount = 0;
    correctCount = 0;
    
    
    while(~converged)
        renderVisFrame(PS,'FIX');
        Screen('Flip',PS.window);
        
        trialCount = trialCount + 1;
        
        if(trialCount == 1)
            WaitSecs(4);
        else
            WaitSecs(0.5);
        end
        
        
        if(target(trialCount))
            % Correct answer is "1"
            answer = 1;
            y = sig;
            z = dummy;
        else
            % Correct answer is "2"
            answer = 2;
            y = dummy;
            z = sig;
        end
        
        if ear == 1
            y = [y; zeros(size(y))];
            z = [z; zeros(size(z))];
        else
            y = [zeros(size(y)); y];
            z = [zeros(size(z)); z];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear Up buffers for 1st stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        sens = phoneSens(fc); % in dB SPL / 0 dBV (frequency specific)
        % Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
        % to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
        % SPL for pure tones occupying full range in MATLAB. To get a level
        % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. Of
        % these, we want to attenuate digitally by 40 dB and rest by
        % analog.
        
        digDrop = 40;
        drop = sens + 10.5236 - L - digDrop;
        %Start dropping from maximum RMS (actual RMS not peak-equivalent)
        wavedata = y * db2mag(-1 * digDrop); %
        %-----------------------------------------
        % Attenuate both sides, just in case
        invoke(PS.RP, 'SetTagVal', 'attA', drop);
        invoke(PS.RP, 'SetTagVal', 'attB', drop);
        
        
        % The trial flow:
        if useTDT
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
            WaitSecs(0.1);
            %Start playing from the buffer:
            Screen('DrawText',PS.window,'1',PS.rect(3)/2 - 20,PS.rect(4)/2-20,PS.white);
            Screen('Flip',PS.window);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
        else
            sound(y,fs);
        end
        
        WaitSecs(1.4);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Setup 2nd stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        digDrop = 40;
        drop = sens + 10.5236 - L - digDrop;
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
        
        WaitSecs(1);
        
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
            Llist = [Llist, L];
        else
            fprintf(1,'..which is Wrong!\n');
            respList = [respList, 0];
            correct = 0;
            Llist = [Llist, L];
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Feedback Frame
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if(feedback)
            if(correct)
                renderVisFrame(PS,'GO');
                correctCount = correctCount +1;
                
            else
                renderVisFrame(PS,'NOGO');
                
            end
        end
        if(correct)
            if(geometric)
                L = L*stepDown;
            else
                L = L + stepDown;
            end
        else
            if(geometric)
                L = L*stepUp;
            else
                L = L + stepUp;
            end
        end
        
        if fc >= 10000
            if( L > 95)
                L = 95;
            end
        elseif L > 85
            L = 85;
        end
        
        
        if (L < -20)
            L = -20;
        end
        
        Screen('Flip',PS.window);
        WaitSecs(feedbackDuration + rand*0.1);
        
        % Counting Reversals
        revList = [];
        downList = [];
        upList = [];
        nReversals = 0;
        for k = 3:numel(Llist)
            if((Llist(k-1) > Llist(k)) && (Llist(k-1) > Llist(k-2)))
                nReversals = nReversals + 1;  revList = [revList, (k-1)];
                downList = [downList, (k-1)];
            end
            if((Llist(k-1) < Llist(k)) && (Llist(k-1) < Llist(k-2)))
                nReversals = nReversals + 1;  revList = [revList, (k-1)];
                upList = [upList, (k-1)];
            end
        end
        
        if(nReversals >= 2)
            if(geometric)
                stepDown = 0.9;
                stepUp = (1/stepDown)^Nup;
            else
                stepDown = -3;
                stepUp = Nup*(-stepDown);
            end
            
            
        end
        
        
        if ((nReversals >= 11) && (trialCount > NminTrials)) || ...
                trialCount >= NmaxTrials
            converged = 1;
        else
            converged = 0;
        end
        
    end
    
    thresh = median(Llist(upList)) * 0.25 + 0.75 * median(Llist(downList)); %#ok<*AGROW>
    
    % Save respList
    
    fprintf(2,'\n###### THRESHOLD FOR THIS BLOCK IS %f\n',thresh);
    toc(tstart);
    datetag = datestr(clock);
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,'-')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname_resp = strcat(respDir,sID,'_',num2str(fc),...
        'Hz_',datetag,'.mat');
    save(fname_resp,'Llist','respList','thresh','fc');
    
    
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
    close_play_circuit(PS.f1,PS.RP);
    
catch %#ok<CTCH>
    
    
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
        save(fname_resp,'Llist','respList','fc');
    end
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    % To see error description.
    psychrethrow(psychlasterror);
end

