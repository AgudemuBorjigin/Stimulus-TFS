function [CF] = CFinsertDepth(numEltd, insertDepth, arrayLength)
% spacing: mm 
% parameters for cochlear frequency positioning function, Greenwood, 1990
A = 165.4; a = 0.06; k = 1;
CF = zeros(1, numEltd);
x = zeros(1, numEltd);

spacing = arrayLength/(numEltd-1);
for i = 1:numEltd
    % length of cochlea is 35 mm
    x(i) = 35 - (insertDepth -  spacing*(i-1));
    CF(i) = A*(10^(a*x(i)) - k);
end
end