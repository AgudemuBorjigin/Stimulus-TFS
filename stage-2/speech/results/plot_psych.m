function plot_psych(data, lineStyle, lineW)
SNRs = unique(data(:,4));
numSNR = numel(SNRs);
score = zeros(1, numSNR);
scorestd = zeros(1, numSNR);
ntrials = zeros(1, numSNR); 
for k = 1:numel(SNRs)
    resp_SNR = data(data(:, 4) == SNRs(k), 2);
    target_SNR = data(data(:, 4) == SNRs(k), 3);
    ntrials(k) = sum(data(:, 4) == SNRs(k));
    score(k) = sum(resp_SNR == target_SNR) / ntrials(k);
    scorestd(k) = score(k)*(1-score(k))/sqrt(ntrials(k));
end

h = errorbar(SNRs, score, scorestd, 'x', 'linew', lineW);
color = get(h, 'Color');
hold on;
% http://matlaboratory.blogspot.com/2015/04/introduction-to-psychometric-curves-and.html
targets = [0.25, 0.5, 0.75];
[~, ~, curve, ~] = FitPsycheCurveLogit(SNRs, score, ones(1, length(SNRs)), targets);
plot(curve(:,1), curve(:,2), 'LineStyle', lineStyle, 'color', color, 'linew', lineW);
end