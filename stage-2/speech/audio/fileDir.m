function out = fileDir(root_audios, speaker, wordlist, target)
fname = [speaker, '_b', num2str(wordlist), '_w',...
    num2str(target), '_orig.wav'];
fpath = [root_audios, '/words/', speaker];
out = fullfile(fpath, fname);
end