function [sig] = sigNorm(sig)
% sigExtraction = sig(abs(sig)>0.01); % it may also excludes
% the natural silence period (pause) between words
index = find(abs(sig)>eps(1));
sigExtraction = sig(index(1):index(end));
sigRMS = rms(sigExtraction);
sig = sig/sigRMS;
end