ramp = 0.005; % AB: gating with 50-ms raised-cosine ramps
L = 70; % AB: Fixed value at 70 dBSPL

if(useTDT)
    %Clearing I/O memory buffers: AB
    invoke(PS.RP,'ZeroTag','datainL');
    invoke(PS.RP,'ZeroTag','datainR');
end

%% Starting the task
tstart = tic;

renderVisFrame(PS,'FIX');
Screen('Flip',PS.window);
WaitSecs(1); % waiting for stablizing at the end

% visual cue to tell subject where to pay attention to
trig_arrw = bin2dec(strcat(int2str(streamType),int2str(pitchType))) + 1;
if attenDir == 1
    tarDir = 'left';
    trig_arrw = trig_arrw + 8 + 4;
    invoke(PS.RP, 'SetTagVal', 'trgname', trig_arrw); % set trigger for the response frame
    % left arrow
    renderVisFrame(PS, 'CUEL');
    Screen('Flip',PS.window);
    invoke(PS.RP, 'SoftTrg', 6); %send trigger immediately after 6
else
    tarDir = 'right';
    trig_arrw = trig_arrw + 8;
    invoke(PS.RP, 'SetTagVal', 'trgname', trig_arrw); % set trigger for the response frame
    % right arrow
    renderVisFrame(PS, 'CUER');
    Screen('Flip',PS.window);
    invoke(PS.RP, 'SoftTrg', 6); %send trigger immediately after 6
end
WaitSecs(0.35);
renderVisFrame(PS,'FIX');
Screen('Flip',PS.window);
% spatially separated high and low streams
[stream] = makeAttStim(nRep_current, nRepNonTar_current, tarDir, streamType, pitchType, ITD, fs, ramp);
scale = (rms(stream(1,:)) + rms(stream(2,:)))/2;
answer = nRep_current;

trigger = trig_arrw -8;
% CHANGE AS NEEDED: left atten: short stream, low & high (3, 4)
%                   left atten: long stream, low & high (1, 2)
%                   right atten: short stream, low & high (7, 8)
%                   right atten: long stream, low & high (5, 6)

% sending the stimulus to corresponding ear
y = [stream(1,:); stream(2,:)];

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear Up buffers for 1st stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if earPhone == 0
    sens = phoneSens(1000);
else
    sens = phoneSens_ER2(1000);
end
% in dB SPL / 0 dBV (frequency specific)
% Without attenuation, RZ6 gives 10.5236 dBV (matlab is restricted
% to +/- 0.95 by scaleSound). So you would get sens + 10.5236 dB
% SPL for pure tones occupying full range in MATLAB. To get a level
% of 'L' dB SPL, you need to attenuate by sens + 10.5236 - L. This
% is for a tone which would have an rms of 0.95/sqrt(2).
% For a different waveform of rms 'scale', we should adjust further
% by db(scale*sqrt(2)/0.95).

digDrop = 40; % How much to drop digitally
drop = sens + 10.5236 - L - digDrop + db(scale*sqrt(2)/0.95);
%Start dropping from maximum RMS (actual RMS not peak-equivalent)
wavedata = y * db2mag(-1 * digDrop); % AB: signal remains the same when digDrop = 0


% The trial flow:
if useTDT
    %Load data onto RZ6
    invoke(PS.RP, 'SetTagVal', 'nsamps', size(wavedata,2));
    invoke(PS.RP, 'SetTagVal', 'trgname', trigger); % trigger for attended streams with different timing, different pitch
    invoke(PS.RP, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
    invoke(PS.RP, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
    %Start playing from the buffer:
    WaitSecs(1.9);
    %-----------------------------------------
    % Attenuate both sides, just in case
    invoke(PS.RP, 'SetTagVal', 'attA', drop);
    invoke(PS.RP, 'SetTagVal', 'attB', drop);

    invoke(PS.RP, 'SoftTrg', 1); %Playback trigger
    WaitSecs(ceil(size(wavedata,2)/fs));
else
    sound(y,fs);
end

WaitSecs(0.5);

%-----------------------------------------
% Attenuate both sides, just in case
invoke(PS.RP, 'SetTagVal', 'attA', 120);
invoke(PS.RP, 'SetTagVal', 'attB', 120);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Response Frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

renderVisFrame(PS,'RESP');
trig_resp = 17;
invoke(PS.RP, 'SetTagVal', 'trgname', trig_resp); % set trigger for the response frame
Screen('Flip',PS.window);
invoke(PS.RP, 'SoftTrg', 6); %send trigger
if(buttonBox)
    resp = getResponse(PS.RP);
else
    resp = getResponseKb;
end

fprintf(1,'\n Target = %s, Response = %s',num2str(answer),num2str(resp));
if((numel(resp)>=1) && ((answer - resp(end)) == 0))
    fprintf(1,'..which is correct!\n');
    correct = 1;
    trig_corrt = 18;
else
    fprintf(1,'..which is Wrong!\n');
    correct = 0;
    trig_corrt = 19;
end

invoke(PS.RP, 'SetTagVal', 'trgname', trig_corrt); % trigger for the correctness

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
invoke(PS.RP, 'SoftTrg', 6); %send trigger
WaitSecs(feedbackDuration + rand*0.1); % AB: jitter

toc(tstart);
