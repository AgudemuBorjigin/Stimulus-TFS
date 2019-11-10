subj = 'S123';
cond = 'space';
flag_c = 1;
while flag_c
    switch cond
        case 'anechoic'
            SNRs = -22:5:8;
            flag_c = 0;
        case 'pitch'
            SNRs = -15:5:10;
            flag_c = 0;
        case 'space'
            SNRs = -15:5:10; 
            flag_c = 0;
        case 'echo'
            SNRs = -20:5:10; 
            flag_c = 0;
        case 'sum'
            SNRs = -18:3:-3;
            flag_c = 0;
        otherwise
            fprintf(2, 'Unrecognized configuration type! Try again!\n');
    end
end
rootPath = 'C:\Experiments\Agudemu\stimulus-TFS\stage-2\speech\results\';
files = dir(strcat(rootPath, cond, '\', subj));
load(strcat(rootPath, cond, '\', subj, '\', files(end-1).name));

for k = 1:numel(SNRs)
    resp_SNR = responseTable(responseTable(:, 4) == SNRs(k), 2);
    target_SNR = responseTable(responseTable(:, 4) == SNRs(k), 3);
    ntrials(k) = sum(responseTable(:, 4) == SNRs(k)); %#ok<SAGROW>
    score(k) = sum(resp_SNR == target_SNR) / ntrials(k); %#ok<SAGROW>
    scorestd(k) = score(k)*(1-score(k))/sqrt(ntrials(k)); %#ok<SAGROW>
    snr_label{k} = num2str(SNRs(k)); %#ok<SAGROW>
end
errorbar(SNRs, score, scorestd, 'xb', 'linew', 2);
title(strcat(cond, '-', subj));
xlabel('SNR (dB)', 'fontsize', 16);
ylabel('Proportion Correct', 'fontsize', 16);
grid on;
xticks(SNRs);
xticklabels(snr_label);
