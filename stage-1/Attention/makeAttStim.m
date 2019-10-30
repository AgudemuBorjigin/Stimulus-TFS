function [stream] = makeAttStim(nRep, nRepNonTar, tarDir, streamType, pitchType, ITD, fs, ramp)

% USAGE:
%   [stream] = makeAttenStim(nRep, tarLoc, ITD, fs, ramp)
% INPUTS:
%   fs: Sampling rate (Hz)
%   ramp: Duration of ramp on either end (s)
%
% OUTPUTS:
%   stream: Generated stimulus 
%
%--------------------------------------
% Copyright Agudemu Borjigan. All Rights Reserved
%--------------------------------------
[daHigh, ~] = audioread('da_resampled.wav'); 
[baHigh, ~] = audioread('ba_resampled.wav'); 
[baLow, ~] = audioread('ba3_resampled.wav'); 
[daLow, ~] = audioread('da3_resampled.wav');

vowelsTar = cell(1,6);
vowelsNonTar = cell(1,6);
nAll = 6;

if pitchType
    highLoc = tarDir;
else
    highLoc = '';
end

% CHANGE AS NEEDED
onsetsLong = floor([0 0.9 2.0 3.1 4.2 5.1]*fs);
onsetsShort = floor([0 0.5 1.5 2.6 3.7 4.6]*fs);
streamTar = zeros(1, floor(6*fs));
streamNonTar = zeros(1, floor(6*fs));
if streamType
    onsetsTar = onsetsShort;
    onsetsNonTar = onsetsLong;
else
    onsetsTar = onsetsLong;
    onsetsNonTar = onsetsShort;
end

% nAll vowels in a target stream, nRep ba(s)
for i = 1:nRep
    if strcmp(highLoc, tarDir)
        vowelsTar{i} = baHigh;
    else
        vowelsTar{i} = baLow;
    end
end
for i = nRep+1:nAll
    if strcmp(highLoc, tarDir)
        vowelsTar{i} = daHigh;
    else
        vowelsTar{i} = daLow; 
    end
end


% nAll vowels in the other stream, random number of ba(s)
for i = 1:nRepNonTar
    if strcmp(highLoc, tarDir)
        vowelsNonTar{i} = baHigh;
    else
        vowelsNonTar{i} = baLow; 
    end
end
for i = nRepNonTar+1:nAll
    if strcmp(highLoc, tarDir)
        vowelsNonTar{i} = daHigh;
    else
        vowelsNonTar{i} = daLow; 
    end
end

% shuffeling the order of ba and da in high and low streams
vowelsTar = vowelsTar(randperm(nAll));
vowelsNonTar = vowelsNonTar(randperm(nAll));

% inserting vowels into the fixed positions
for i = 1:nAll
    streamTar(onsetsTar(i)+1:onsetsTar(i)+length(vowelsTar{i})) = vowelsTar{i};
    streamNonTar(onsetsNonTar(i)+1:onsetsNonTar(i)+length(vowelsNonTar{i})) = vowelsNonTar{i};
end

% applying ITD
% far, near is from the point of view of left ear
ITDarray = zeros(1,floor(2*ITD*fs));
if strcmp(tarDir, 'left')
    near = streamTar;
    far = streamNonTar;
else
    near = streamNonTar;
    far = streamTar;
end

chann1 = cat(2, ITDarray, far);
chann2 = cat(2, near, ITDarray);

left = chann1+chann2;
left = rampsound(left, fs, ramp);
left = left/rms(left);
left = scaleSound(left);

chann3 = cat(2, ITDarray, near);
chann4 = cat(2, far, ITDarray);

right = chann3+chann4;
right = rampsound(right, fs, ramp);
right = right/rms(right);
right = scaleSound(right);

stream = [left;right];
end