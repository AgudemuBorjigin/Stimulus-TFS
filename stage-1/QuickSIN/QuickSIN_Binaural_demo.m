function QuickSIN_Binaural_demo(location,type)
% location: 'colocated' or 'separated'
% type: 'intact' or 'env' or 'tfs'
paraDir = 'C:\AgudemuCode\Stimulus\QuickSIN\';

pathstuff = genpath(paraDir);
addpath(pathstuff);

% Some settings
if strcmp(location, 'colocated')
    maxSNR = 12;
    minSNR = -3;
else
    maxSNR = 9;
    minSNR = -6;
    listDiff = 5;
end
nlists = 5;

FsampTDT = 4; % 100 kHz
useTrigs = 0;
useTDT = 1;
screenDist = 0.4;
screenWidth = 0.3;
buttonBox = 1; %#ok<NASGU>

PS = psychStarter(useTDT,screenDist,screenWidth,useTrigs,FsampTDT);

try
    fs = 100e3; 
    L = 70;
    for list = 1:nlists
        
        if strcmp(location, 'separated') % DELETE AS NEEDED: temporary for testing
            list = list + listDiff; %#ok<FXSET>
        end
        
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
        for SNR = maxSNR+6:-3:minSNR
            if SNR == maxSNR+6 % for reference
                info = strcat('This is the person you should listen to: reference 1');
                Screen('DrawText',PS.window,info,textlocH,textlocV + 3*line2line,PS.white);
                Screen('Flip',PS.window);
                WaitSecs(1);
                fname = ['./soundmatsHarvard/', location, '/', type, '/', 'List', num2str(list), '_reference1.mat'];
            elseif SNR == maxSNR+3 % for reference
                info = strcat('This is the person you should listen to: reference 2');
                Screen('DrawText',PS.window,info,textlocH,textlocV + 3*line2line,PS.white);
                Screen('Flip',PS.window);
                WaitSecs(1);
                fname = ['./soundmatsHarvard/', location, '/', type, '/', 'List', num2str(list), '_reference2.mat'];
            else
                SNRk = SNRk + 1;
                info = strcat('Sentence #', num2str(SNRk), '/6');
                Screen('DrawText',PS.window,info,textlocH,textlocV + 3*line2line,PS.white);
                Screen('Flip',PS.window);
                fname = ['./soundmatsHarvard/', location, '/', type, '/', 'List', num2str(list), '_', num2str(SNR), '.mat'];
            end
            
            load(fname, 'out');
            %resample
            out = out';
            out = resample(out, fs, 44100); % soundmats have original sampling rate of 44100;
            y = out';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Clear Up buffers for 1st stim
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            sens = phoneSens(1000); % in dB SPL / 0 dBV (frequency specific)
            % Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
            % to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
            % SPL for pure tones occupying full range in MATLAB. To get a level
            % of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. Of
            % these, we want to attenuate digitally by 40 dB and rest by
            % analog.
            
            digDrop = 0; % 40 or 0
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