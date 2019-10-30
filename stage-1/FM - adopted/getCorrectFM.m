function [correct] = ...
    getCorrectFM(sID, ear, fc, fm, fdev, dur, ramp, trialNum, BlockNum, useTDT, buttonBox, PS)

% USAGE:

%% Variable initialization
feedback = 1; % AB
feedbackDuration = 0.2; % AB
%%
try
    fs = 48828.125;
    L = 70; % AB: Fixed value at 70 dBSPL
    
    if(useTDT)
        %Clearing I/O memory buffers: AB
        invoke(PS.RP,'ZeroTag','datainL');
        invoke(PS.RP,'ZeroTag','datainR');
    end
    
    
    textlocH = PS.rect(3)/3;
    textlocV = PS.rect(4)/2.2;
    trialNumStr = num2str(trialNum);
    BlockNumStr = num2str(BlockNum);
    info = strcat('This is trial #',trialNumStr,'/ Block',BlockNumStr,'...');
    Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
    Screen('Flip',PS.window);
    WaitSecs(1); % AB
    
    %% Starting the task
    tstart = tic;
    
    % target (FM) and dummy non-target (pure tone)
    sig = makeFMstim_tones(fdev, fc, fs, fm,...
        dur, ramp);
    dummy = makeFMstim_tones(0, fc, fs, fm, dur, ramp);
    scale = (rms(sig) + rms(dummy))/2; 
    
    renderVisFrame(PS,'FIX'); 
    Screen('Flip',PS.window); 
    
    % AB: randomizing the order of playing FM and pure tones
    if randi(2) == 1
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
    
    % sending the stimulus to corresponding ear
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
    % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. This
    % is for a tone which would have an rms of 0.95/sqrt(2).
    % For a different waveform of rms 'scale', we should adjust further
    % by db(scale*sqrt(2)/0.95).
    
    digDrop = 0; % How much to drop digitally
    drop = sens + 10.5236 - L - digDrop + db(scale*sqrt(2)/0.95);
    %Start dropping from maximum RMS (actual RMS not peak-equivalent)
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
        %Screen('DrawText',PS.window,'1',PS.rect(3)/2 - 20,PS.rect(4)/2-20,PS.white);
        renderVisFrame(PS,'FIX'); % renderVisFrame: function for displaying default symbols on screen
        Screen('Flip',PS.window);
        invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
    else
        sound(y,fs);
    end
    
    WaitSecs(1.4);
    
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
    
    WaitSecs(1);
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
        correct = 1;
    else
        fprintf(1,'..which is Wrong!\n');
        correct = 0;
    end
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Feedback Frame
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(feedback)
        if(correct)
            renderVisFrame(PS,'GO'); % AB
            
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
        fname_resp = strcat(respDir,sID,'_',num2str(fc),...
            'Hz_crash_',datetag,'.mat');
        save(fname_resp,'correct','fc');
    end
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    % To see error description.
    rethrow(me);
end

