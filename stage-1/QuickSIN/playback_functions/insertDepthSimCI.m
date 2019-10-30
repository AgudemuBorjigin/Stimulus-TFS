function [sigCIout] = insertDepthSimCI(sig, fs, insertDepth, arrayLength, numEltd)
% analysis (reference) CFs
CF = exp(linspace(log(80), log(8820), numEltd));

sigFilter = BPFbank(sig, fs, CF);
sigEnv = zeros(numel(CF), length(sig));
sigTFS = zeros(numel(CF), length(sig));
sigCI = zeros(numel(CF), length(sig));

for i = 1:numel(CF)
    sigEnv(i, :) = abs(hilbert(sigFilter(i,:)));% use abs instead of real
    sigTFS(i, :) = angle(hilbert(sigFilter(i, :)));
end

CFshifted = CFinsertDepth(numEltd, insertDepth, arrayLength);
% t = 0:1/fs:length(sig)/fs-1/fs;
for i = 1:numel(CFshifted)
    % Tone vocoding
    % carr = sin(2*pi*CFshifted(i)*t);

    % Noise vocoding
    % noise = randn(1, numel(t));
    % carr = noise;
    
    % Pulse train vocoding
    % pps = 130;
    % carr = zeros(size(t));
    % carr(rem(t, 1/pps) < eps) = 1;
    
    % Transposing original TFS
    if CFshifted(i) < 1.5e3
        carr = cos(CFshifted(i)/CF(i) * sigTFS(i, :));
    else
        noise = randn(1, numel(sig));
        carr = noise;
    end
    
    sigCI(i, :) = sigEnv(i, :).*carr;
    sigCI(i, :) = BPFbank(sigCI(i, :), fs, CFshifted(i));
end
sigCI = sum(sigCI);
sigCIout = scaleSound(sigCI);
end