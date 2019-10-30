load stalbans.mat;
% soundsc(x,fs); % "Two blue fish swam in the tank"
xConv = conv(x,h);
% soundsc(xConv,fs);% The same sentence with reverbration
x = [x zeros(1,length(h)-length(x))]; % Making x the same length as h
xf = fft(x);
hf = fft(h);
xhf = xf.*hf;
xhif = ifft(xhf);
soundsc(xhif,fs);% The same echoed sound, but obtained from multiplication of signal and filter 
% in frequency domain instead of convolution in time domain




