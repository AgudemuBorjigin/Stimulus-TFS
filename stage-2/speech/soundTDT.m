function soundTDT(y, RZ, level)
stimlength = size(y, 1);
stimrms = 0.02; % All stims are generated this way
chanL = y(:, 1);
chanR = y(:, 2);
%-----------------
% Why 111 for ER-2?
%-----------------
% ER-2s give about 100dB SPL for a 1kHz tone with a 1V-rms drive.
% Max output is +/-5V peak i.e 3.54V-rms which is 11 dB higher.
% Thus 111 dB-SPL is the sound level for tones when they occupy full
% range.

% Full range in MATLAB for a pure tone is +/- 1 which is 0.707 rms and
% that corresponds to 111 dB SPL at the end. So if we want a signal
% with rms sigrms to be x dB, then (111 - x) should be
% db(sigrms/0.707).

drop = 111 - level + 3 + db(stimrms); % The extra 3 for the 0.707 factor

stimTrigger = 1; % Does nothing here
invoke(RZ, 'SetTagVal', 'trigval', stimTrigger);
invoke(RZ, 'SetTagVal', 'nsamps', stimlength);
invoke(RZ, 'WriteTagVEX', 'datainL', 0, 'F32', chanL); %write to buffer left ear
invoke(RZ, 'WriteTagVEX', 'datainR', 0, 'F32', chanR); %write to buffer right ear

invoke(RZ, 'SetTagVal', 'attA', drop); %setting analog attenuation L
invoke(RZ, 'SetTagVal', 'attB', drop); %setting analog attenuation R

WaitSecs(0.05); % Just giving time for data to be written into buffer
%Start playing from the buffer:
invoke(RZ, 'SoftTrg', 1); %Playback trigger