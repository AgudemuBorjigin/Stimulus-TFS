function [correct] = getCorrectITD(leftOrRight, sID, fc, ITD, dur, ramp, trigNum, trialNum, BlockNum,useTDT,...
    buttonBox, PS)

feedback = 1;
feedbackDuration = 0.2;

try
    fs = 100e3; % 100 KHz
    L = 70; % set everything to 70
    
    if(useTDT)
        %Clearing I/O memory buffers:
        invoke(PS.RP,'ZeroTag','datainL');
        invoke(PS.RP,'ZeroTag','datainR');
    end
%     textlocH = PS.rect(3)/3;
%     textlocV = PS.rect(4)/2.2;
%     trialNumStr = num2str(trialNum);
%     BlockNumStr = num2str(BlockNum);
%     info = strcat('This is trial #',trialNumStr,'/ Block',BlockNumStr,'...');
%     Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
%     Screen('Flip',PS.window);
    WaitSecs(0.2); % AB
    
    %% Startig the task
    tstart = tic;
    
    renderVisFrame(PS,'FIX');
    Screen('Flip',PS.window);
    % ITDs with different directions in two itervals (pure tone)
    if leftOrRight
        % correct answer is 1
        sig1 = makeITDstim_freqdomain(ITD, 1, fc, fs,...
            dur, ramp);
        
        sig2 = makeITDstim_freqdomain(ITD, 0, fc, fs,...
            dur, ramp);
        answer = 1;
    else
        % correct answer is 2
        sig1 = makeITDstim_freqdomain(ITD, 0, fc, fs,...
            dur, ramp);
        
        sig2 = makeITDstim_freqdomain(ITD, 1, fc, fs,...
            dur, ramp);
        answer = 2;
    end
    
    scale = (rms(sig1(1,:)) + rms(sig2(2,:)))/2;
    y = sig1;
    z = sig2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Clear Up buffers for 1st stim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % If using headphones (HDA 300), we have to use the phoneSens.m
    % function, but ER-1s are plat spectrum with fixed sensitivity.
    
    % sens = 100; % in dB SPL / 0 dBV (frequency specific)
    sens = phoneSens(fc);
    % Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
    % to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
    % SPL for pure tones occupying full range in MATLAB. To get a level
    % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. This
    % is for a tone which would have an rms of 0.95/sqrt(2).
    % For a different waveform of rms 'scale', we should adjust further
    % by db(scale*sqrt(2)/0.95).
    
    digDrop = 0; % How much to drop digitally
    drop = sens + 10.5236 - L - digDrop + db(scale*sqrt(2)/0.95); % db(scale*sqrt(2)/0.95) is the compensation considering the real signal
    %Start dropping from maximum RMS (actual RMS not peak-equivalent)
    wavedata = y * db2mag(-1 * digDrop);
    %-----------------------------------------
    % Attenuate both sides, just in case
    invoke(PS.RP, 'SetTagVal', 'attA', drop);
    invoke(PS.RP, 'SetTagVal', 'attB', drop);
    
    
    % The trial flow:
    if useTDT
        %Load data onto RZ6
        invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
        invoke(PS.RP, 'SetTagVal', 'trgname', trigNum);
        invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
        invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
        WaitSecs(0.1);
        %Start playing from the buffer:
        %Screen('DrawText',PS.window,'Start',PS.rect(3)/2.1 - 20,PS.rect(4)/2.2-20,PS.white);
        renderVisFrame(PS,'FIX');
        Screen('Flip',PS.window);
        invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
    else
        sound(y,fs);
    end
    
    WaitSecs(dur + 0.2); % make sure there is a delay after the stimulus
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Clear Up buffers for 2nd stim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wavedata = z * db2mag(-1 * digDrop);
    %-----------------------------------------
    % Attenuate both sides, just in case
    invoke(PS.RP, 'SetTagVal', 'attA', drop);
    invoke(PS.RP, 'SetTagVal', 'attB', drop);
    
    % The trial flow:
    if useTDT
        %Load data onto RZ6
        invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
        invoke(PS.RP, 'SetTagVal', 'trgname', trigNum);
        invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
        invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
        WaitSecs(0.1);
        %Start playing from the buffer:
        %Screen('DrawText',PS.window,'Start',PS.rect(3)/2.1 - 20,PS.rect(4)/2.2-20,PS.white);
        renderVisFrame(PS,'FIX');
        Screen('Flip',PS.window);
        invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
    else
        sound(y,fs);
    end
    
    WaitSecs(dur + 0.5); % make sure there is a delay after the stimulus
    
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
        correct = 1;
    else
        fprintf(1,'..which is Wrong!\n');
        correct = 0;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Feedback Frame
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(feedback)
        if(correct)
            renderVisFrame(PS,'GO');
            
        else
            renderVisFrame(PS,'NOGO');
            
        end
    end
    
    Screen('Flip',PS.window);
    WaitSecs(feedbackDuration + rand*0.1);
    
    toc(tstart);
    
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
        fname_resp = strcat(respDir,sID,'_',num2str(ITD),...
            '_crash_',datetag,'.mat');
        save(fname_resp, 'ITD', 'correct', 'fc');
    end
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    % To see error description.
    rethrow(me);
end

