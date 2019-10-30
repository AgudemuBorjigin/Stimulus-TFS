datadir = 'C:\AgudemuCode\Stimulus\Screening\subjResponses\';
subjs = dir(strcat(datadir, '*Ear'));
fid = fopen('AudiogramData.csv', 'w');
freqs  = [0.5, 1, 2, 4, 8]*1000;
fprintf(fid, 'Subject, Ear, 500, 1000, 2000, 4000, 8000\n');
for k = 1:numel(subjs)
    subj = subjs(k);
    sID = subj.name(1:2);
    ear = subj.name(4);
    fprintf(fid, '%s, %s', sID, ear);
    for freq = freqs
        fsearch = strcat(subj.folder, '\', subj.name, '\', subj.name, '_', ...
            num2str(freq), '*.mat');
        fnames = dir(fsearch);
        ftemp = fnames(1);
        fname = ftemp.name;
        data = load(strcat(subj.folder, '\', subj.name, '\', fname), 'thresh');
        fprintf(fid, ',%f',data.thresh);
    end
    fprintf(fid, '\n');
end
fclose(fid);

