fclist = 1e3 * [0.5, 1, 2, 4, 8];

subj = input('Please subject ID:', 's');
earflag = 1;
while earflag == 1
    ear = input('Please enter which year (L or R):', 's');
    switch ear
        case {'L', 'l', 'Left', 'left', 'LEFT'}
            earname = 'LeftEar';
            earnumber = 1;
            earflag = 0;
        case {'R', 'r', 'Right', 'right', 'RIGHT'}
            earname = 'RightEar';
            earnumber = 2;
            earflag = 0;
        otherwise
            fprintf(2, 'Unrecognized ear type! Try again!');
    end
end
sID = strcat(subj, '_',earname);

for k = 1:numel(fclist)
    fc = fclist(k);
    [respList, Llist, thresh] = getThresh(sID, fc, k, numel(fclist), earnumber, 1, 0.4, 0.3, 1);
    fprintf(1, 'Threshold at %d kHz is %f dB\n', fc, thresh);
end
