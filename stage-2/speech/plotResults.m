SNRs = -20:4:4; % OLD: -20:5:5;
for k = 1:numel(SNRs)
    resp_SNR = responseTable(responseTable(:, 4) == SNRs(k), 2);
    target_SNR = responseTable(responseTable(:, 4) == SNRs(k), 3);
    ntrials(k) = sum(responseTable(:, 4) == SNRs(k)); %#ok<SAGROW>
    score(k) = sum(resp_SNR == target_SNR) / ntrials(k); %#ok<SAGROW>
    scorestd(k) = score(k)*(1-score(k))/sqrt(ntrials(k)); %#ok<SAGROW>
end
errorbar(SNRs - 0.5, score, scorestd, 'xb', 'linew', 2);
xlabel('SNR (dB)', 'fontsize', 16);
ylabel('Proportion Correct', 'fontsize', 16);
set(gca, 'FontSize', 16, 'XTick', [1000, 2000, 4000, 8000]);
grid on;
set(gca, 'FontSize', 16, 'XTick', SNRs);
