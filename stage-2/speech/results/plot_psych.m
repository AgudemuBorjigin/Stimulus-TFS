function [color_out, p] = plot_psych(data, lineStyle, lineW, color_in)
SNRs = unique([data{:, 4}]);
numSNR = numel(SNRs);
scores = zeros(1, numSNR);
scorestd = zeros(1, numSNR);
ntrials = zeros(1, numSNR);

for i = 1:numSNR
    resp_SNR = [data{[data{:, 4}] == SNRs(i), 2}];
    target_SNR = [data{[data{:, 4}] == SNRs(i), 3}];
    ntrials(i) = sum([data{:, 4}] == SNRs(i));
    scores(i) = sum(resp_SNR == target_SNR) / ntrials(i);
    scorestd(i) = scores(i)*(1-scores(i))/sqrt(ntrials(i));
end

if isempty(color_in)
    h = errorbar(SNRs, scores, scorestd, 'x', 'linew', lineW);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    color_out = get(h, 'Color');
else
    h = errorbar(SNRs, scores, scorestd, 'x', 'linew', lineW, 'Color', color_in);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    color_out = color_in;
end
hold on;
% http://matlaboratory.blogspot.com/2015/04/introduction-to-psychometric-curves-and.html
targets = [0.25, 0.5, 0.75];
[~, ~, curve, ~] = FitPsycheCurveLogit(SNRs, scores, ones(1, length(SNRs)), targets);
p = plot(curve(:,1), curve(:,2), 'LineStyle', lineStyle, 'color', color_out, 'linew', lineW);
end