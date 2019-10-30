function QuickSIN_Binaural_20lists(location,type)
% location: 'colocated' or 'separated'
% type: 'intact' or 'env' or 'tfs'
paraDir = 'C:\AgudemuCode\Stimulus\QuickSIN\';

pathstuff = genpath(paraDir);
addpath(pathstuff);

% Some settings
nlists = 20;

FsampTDT = 3; % 48828.125 Hz
useTrigs = 0;
useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1;

PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT);

try
    fs = 48828.125;
    L = 70;
    for list = 1:nlists
        
        if(useTDT)
            %Clearing I/O memory buffers:
            invoke(PS.RP,'ZeroTag','datainL');
            invoke(PS.RP,'ZeroTag','datainR');
        end
        textlocH = PS.rect(3)/4;
        textlocV = PS.rect(4)/3;
        line2line = 50;
        blockNumStr = num2str(list);
        totalBlocks = num2str(nlists);
        info = strcat('This is List #',blockNumStr,'/',totalBlocks,'...');
        Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
        info = strcat('Press any button twice to begin...');
        Screen('DrawText',PS.window,info,textlocH,textlocV+line2line,PS.white);
        Screen('Flip',PS.window);
        
        getResponse(PS.RP);
        getResponse(PS.RP);
        
        tstart = tic;
        
        SNRk = 0;
        for SNR = 12:-3:-3
            info = strcat('This is List #',blockNumStr,'/',totalBlocks);
            Screen('DrawText',PS.window,info,textlocH,textlocV,PS.white);
            
            SNRk = SNRk + 1;
            info = strcat('Sentence #', num2str(SNRk), '/6');
            
            Screen('DrawText',PS.window,info,textlocH,textlocV + 3*line2line,PS.white);
            Screen('Flip',PS.window);
            
            fname = ['./soundmatsHarvard/', location, '/', type, '/', 'List', num2str(list), '_', num2str(SNR), '.mat'];
            load(fname);
            y = out;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Clear Up buffers for 1st stim
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
%             y = makeBiSpeechNoise(list,SNR, type,location); % 'intact', 'env', 'tfs'; 'colocated', 'separated'
            
            sens = phoneSens(1000); % in dB SPL / 0 dBV (frequency specific)
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
            
            %Load data onto RZ6
            invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
            invoke(PS.RP, 'SetTagVal', 'trgname', SNRk);
            invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
            invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
            WaitSecs(0.1);
            invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
            WaitSecs(ceil(size(wavedata,2)/fs));
            getResponse(PS.RP);
            getResponse(PS.RP);
        end
    end
    
    toc(tstart);
    
    sca;
    % Restores the mouse cursor.
    ShowCursor;
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    rmpath(pathstuff);
catch me
    sca;
    % Restores the mouse cursor.
    ShowCursor;
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', PS.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', PS.oldSupressAllWarnings);
    close_play_circuit(PS.f1,PS.RP);
    rethrow(me);
end
end