rootPath = '/Users/baoagudemu1/Desktop/Lab/Experiment/stimulus-TFS/stage-2/speech/results';
cond = 'sum';
path = strcat(rootPath, '/', cond, '/S*');
folders = dir(path);
subjs = {folders.name};

for i = 1:numel(subjs)
    files = dir(strcat(rootPath, '/', cond, '/', subjs{i}));
    load(strcat(rootPath, '/', cond, '/', subjs{i}, '/', files(end).name));
    plot_psych(responseTable, '--', 0.5);
    
    if i == 1
        data = responseTable;
    else
        data = [data; responseTable];
    end
    
    if i == numel(subjs)
        plot_psych(data, '-', 2);
    end
end
grid on;
title(cond);
xlabel('SNR (dB)');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16);