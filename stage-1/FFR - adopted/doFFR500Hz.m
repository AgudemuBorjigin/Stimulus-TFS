clear all; close all hidden; clc; %#ok<CLALL>

fig_num=99;
USB_ch=1;

pth = genpath('./functions/');
addpath(pth);

FS_tag = 3;

Fs = 48828.125;


[f1RZ,RZ,FS]=load_play_circuit(FS_tag,fig_num,USB_ch);

% Stimulus parameters
freqs = [475, 500, 525];
dur = 0.5;
t = 0:(1/Fs):(dur - 1/Fs);
ramp = 0.005;
L = 75;
nTrials = 4000;% make sure the trial number is even number since there are two polarities
fi = 0;

% Initiating circuit
invoke(RZ, 'SetTagVal', 'trgname',253);
invoke(RZ, 'SetTagVal', 'onsetdel',100);
invoke(RZ, 'SoftTrg', 6);

pause(2.0);

tstart = tic;
jit = rand(nTrials, 1)*0.005;
y = zeros(2, numel(t));
for fc = freqs
    fi = fi+1;
    for p = 1:nTrials
        y(1,:) = (-1)^p*rampsound(sin(2*pi*fc*t), Fs, ramp); % toggle between positive and negative polarities from trial to trial
        y(2,:) = (-1)^p*rampsound(sin(2*pi*fc*t), Fs, ramp);
        scale = rms(y(1,:));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear Up buffers for 1st stim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % If using headphones (HDA 300), we have to use the phoneSens.m
        % function, but ER-1s are flat spectrum with fixed sensitivity.
        
        sens = 100; % in dB SPL / 0 dBV (frequency specific)
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
        invoke(RZ, 'SetTagVal', 'attA', drop); %setting analog attenuation L
        invoke(RZ, 'SetTagVal', 'attB', drop); %setting analog attenuation R
        invoke(RZ, 'SetTagVal', 'nsamps', size(wavedata,2));
        if mod(p, 2)
            invoke(RZ, 'SetTagVal', 'trgname', 2 + 2*(fi-1)); % trigger for negative polarity
        else
            invoke(RZ, 'SetTagVal', 'trgname', 1 + 2*(fi-1));
        end
        invoke(RZ, 'WriteTagVEX', 'datainL', 0, 'F32', wavedata(1, :));
        invoke(RZ, 'WriteTagVEX', 'datainR', 0, 'F32', wavedata(2, :));
        %Start playing from the buffer:
        invoke(RZ, 'SoftTrg', 1); %Playback trigger
        fprintf(1,' Trial Number %d/%d\n', p, nTrials);
        WaitSecs(dur + 0.05 + jit(p)); % jitter is needed for eeg recording, 25 msec wait time
    end
end

toc(tstart);

%Clearing I/O memory buffers, AB: not sure if changes are required, 3/8/18
invoke(RZ,'ZeroTag','datainL');
invoke(RZ,'ZeroTag','datainR');
pause(3.0);

% Pause On, AB: not sure if changes are required, 3/8/18
invoke(RZ, 'SetTagVal', 'trgname', 254);
invoke(RZ, 'SetTagVal', 'onsetdel',100);
invoke(RZ, 'SoftTrg', 6);

close_play_circuit(f1RZ,RZ);
fprintf(1,'\n Done with data collection!\n');

rmpath(pth);

