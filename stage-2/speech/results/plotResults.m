subj = 'Angel';
numVisit = 1;

os = 'Mac';
if strcmp(os, 'Mac')
    rootPath = '/Users/Agudemu/Desktop/Lab/Experiment/stimulus-TFS/stage-2/speech/results/';
else
    rootPath = '/home/agudemu/Experiment/stimulus-TFS/stage-2/speech/results/';
end

figure;
plotCond(rootPath, numVisit, subj, 'anechoic');
plotCond(rootPath, numVisit, subj, 'pitch');
plotCond(rootPath, numVisit, subj, 'space');
plotCond(rootPath, numVisit, subj, 'sum');
legend('anechoic', 'pitch', 'space', 'sum', 'Location', 'Best');
grid on;
xlabel('SNR (dB)');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16);
title(subj);
%xlim([-25 15]);ylim([0 1]);

figure;
plotCond(rootPath, numVisit, subj, 'echo');
plotCond(rootPath, numVisit, subj, 'echo-pitch');
plotCond(rootPath, numVisit, subj, 'echo-space');
plotCond(rootPath, numVisit, subj, 'echo-sum');
grid on;
xlabel('SNR (dB)');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16);
legend('echo', 'echo-pitch', 'echo-space', 'echo-sum', 'Location', 'Best');
title(subj);
%xlim([-25 15]);ylim([0 1]);