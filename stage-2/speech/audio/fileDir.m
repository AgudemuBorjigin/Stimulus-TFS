function out = fileDir(root_audios, speaker, wordlist, target, pitch, original)
if original
    fname = [speaker, '_b', num2str(wordlist), '_w',...
        num2str(target), '_orig.wav'];
    fpath = [root_audios, '/words/', speaker];
else
    fname = [speaker, '_b', num2str(wordlist), '_w',...
        num2str(target), '_orig_flattened_', num2str(pitch), '.wav'];
    fpath = [root_audios, '/words/', speaker, '_flat_', num2str(pitch), '/'];
end
out = fullfile(fpath, fname);
end