function [out] = BPFbank(in, fs, CF) % in has two channels
% The CF range could be from 80 to 8820 Hz, referenced from Biran C. J.
% Moore, Christian Lorenzi 2006
nf = fs/2;
out = zeros(numel(CF),length(in));

for i = 1:numel(CF)
    % B. Glasberg, B. Moore, 1990 (also refeernced by Michael K. Qin, Andrew J. Oxenham, 2003)
    % Further including asymmetry of auditory filters by using symmetrically-notched noise around CF, compared to the 1987
    % publication
    % low-frequency skirt becomes less sharp with increasing level, while
    % the changes in slope of the high-frequency skirt of the filter with
    % level can be ignored. 
    % BW = 24.7*(4.37*CF(i)+1);
    
    BW = CF(i)/5; % symmetric filters; rule of thumb, works pretty well    
    fLow = BW/2; fHigh = BW/2;
    try
        [b, a] = butter(2,[(CF(i)-fLow)/nf (CF(i)+fHigh)/nf]); % 4th order butterworth filtering
    catch
        fprintf('%f,%f,%f,%f\n', (CF(i)-fLow)/nf, (CF(i)+fHigh)/nf, CF(i), fLow);
    end
    out(i,:) = filtfilt(b,a,in);

%     fd = 2^(1/2*0.35); % Biran C. J. Moore, Christian Lorenzi 2006, 0.35-oct wide adjacent frequency bands spanning 80-8820
%     fHigh = CF(i)*fd;
%     fLow = CF(i)/fd;
%     [b, a] = butter(2,[(CF(i)-fLow)/nf (CF(i)+fHigh)/nf]);

    % Revised estimates of human cochlear tuning from otoacoustic and
    % behavioral measurements Shera et al PNAS 2002, shaper tuning in human
    % may facilitate human speech communication
    % Q_ERB(CF) = CF/ERB(CF), the Q_ERB can be estimated from the measured
    % group delay using OAE: Q_ERB = k*N_BM, where N_BM = 1/2N_SFOAE (N_SFOAE = measured group delay*CF)
end
end