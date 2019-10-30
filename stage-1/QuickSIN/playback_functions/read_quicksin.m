function [y, Fs] = read_quicksin(stimulusType, listNum, snr, reverseChans)
% USAGE:
% read_quicksin: Reads correct quicksin audio when querying by type,
%                list number and SNR
% EXAMPLE:
% [y, Fs] = read_quicksin(stimulusType, listNum, snr, reverseChans)
%
% stimulusType:
%   'calibration': 
%     presents a 1000 Hz tone to both channels (just 10 seconds, rather than
%     the 30 seconds on the CD track)
%   'practice_lists':
%     diotic presentation of lists to familiarize participant with task
%     valid lists: 'A', 'B', or 'C'
%   'diotic_lists'
%     diotic presentation of lists
%     valid lists: 1-18
%   'diotic_lists_hfe'
%     diotic presentation with high-freq emphasis
%     valid lists: 1-16
%   'diotic_lists_hfe_lp'
%     same as "diotic lists hfe", but with LP filter applied
%     valid lists: 1-16
%   'separated_lists'
%     dichotic presentation of target (left) and babble (right)
%     valid lists: 1-12
%     (set "reverseChans" to true (1) to switch channels)
%
%  listNum: choose from amongst the following:
%    'A, 'B', or 'C' for the practice lists
%    1-18 for diotic lists;
%    1-16 for diotic lists hfe or diotic lists hfe lp; 
%    1-12 for separated lists
%    can leave blank when runninng calibration
%
%  snr: 25, 20, 15, 10, 5, 0
%    corresponds to dB SNR; selects the appropriate portion of the track to
%    play back
%    can leave blank when running calibration
%
%  reverseChans: logical
%    set to true (1) to flip L and R channels during playback
%
%
%--------------------
% Copyright Hari Bharadwaj. All rights reserved.
% Nov 3, 2016
%--------------------

if nargin < 4 || isempty(reverseChans)
    reverseChans = false;
end

if nargin < 5
    % pass an empty array to "initialize_playrec_2chan" to bring up selection
    % prompt in command window
    deviceID = [];
end


convertedStimType = lower(strrep(stimulusType, ' ', '_'));

validStimulusTypes = {'calibration', 'practice_lists', 'diotic_lists', ...
                      'diotic_lists_hfe', 'diotic_lists_hfe_lp', ...
                      'separated_lists'};
                  
whichType = strcmp(convertedStimType, validStimulusTypes);

assert(any(whichType), ['Invalid input for stimulusType selected; '...
                        'must be one of: %s, %s, %s, %s, %s'], ...
                        validStimulusTypes{1:6});
                    
assert(sum(whichType) == 1, 'Specify only one stimulus type.');
                    
if strcmp(stimulusType, 'calibration')
    [audioStim, Fs] = audioread(['../original_stimuli/calibration/',...
                                 '1000Hz_calibration_tone.wav']); % CHANGE AS NEEDED
                             
    stimStart = 44100; % AB
    stimEnd = 661499; % AB
    
else
    if ischar(listNum) && ~any(strcmp(listNum, {'A', 'B', 'C'}))
        listNum = str2double(listNum);
    end
    
    if strcmp(stimulusType, 'practice_lists')
        stimStr = '../%s/%s/practice_%s%s';
    else
        stimStr = '../%s/%s/list_%02d%s';
    end
    % check that a valid SNR is selected for playback
    assert(any(snr == [25, 20, 15, 10, 5, 0]), 'invalid SNR specified.');
    
    args = {stimStr, convertedStimType, listNum};
    stimFile = sprintf(args{1}, 'original_stimuli', args{2}, args{3}, '.wav'); %CHANGE AS NEEDED
    timingFile = sprintf(args{1}, 'timings', args{2}, args{3}, '.txt');
    
    [audioStim, Fs] = audioread(stimFile);
    
    % pull sentence demarcation info
    stimTimings = dlmread(timingFile);
    whichRow = stimTimings(:,3) == snr;
    
    stimStart = ceil(stimTimings(whichRow, 1) * Fs);
    stimEnd = ceil(stimTimings(whichRow, 2) * Fs);
    
    if stimEnd > size(audioStim, 1)
        stimEnd = size(audioStim, 1);
    end
    
end

assert(Fs == 44100, 'Sample rate mismatch (expected 44100 Hz, got %d)',...
       Fs);
   
% select the stimulus portion and apply a ramp to onset/offset to avoid
% playback artifacts
toPlay = audioStim(stimStart:stimEnd, :);
ramp = (cos(2*pi*50*(0:1/Fs:0.005)).^2)';
ramp = [ramp, ramp];
rampMult = ones(size(toPlay));
rampMult(1:size(ramp,1),:) = flipud(ramp);
rampMult(end-size(ramp,1)+1:end,:) = ramp;

if reverseChans
    toPlay = fliplr(toPlay);
end

% return
y = toPlay.*rampMult;
end