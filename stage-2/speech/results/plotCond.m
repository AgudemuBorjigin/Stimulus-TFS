function plotCond(rootPath, numVisit, subj, cond)
countV = 0;
for v = 1:numVisit
    filePath = strcat(rootPath, 'visit-', int2str(v), '/', subj);
    if exist(filePath) %#ok<EXIST>
        countV = countV + 1;
        files = dir(filePath);
        load(strcat(filePath, '/', files(end).name)); % LAST FILE IS THE MOST COMPLETE
        ind = strcmp(responseTable(:, 5), cond); %#ok<NODEF>
        dataTmp = responseTable(ind, :);
        % for pooling data across conditions 
        if countV == 1
            [color, p] = plot_psych(dataTmp, '--', 0.5, []);
            set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            dataAll = dataTmp;
        else
            [~, p] = plot_psych(dataTmp, '--', 0.5, color);
            set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            dataAll = [dataAll; dataTmp]; %#ok<AGROW>
        end
    end
    if v == numVisit
        plot_psych(dataAll, '-', 2, color);
    end
end
end