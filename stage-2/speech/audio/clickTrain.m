function train = clickTrain( frq, total_length, width, fs, plotOption )
% 
% Ex-> [train]=clickTrain(40, 1.0, 0.001, 10000, true);
% (1) frq: stimulus frequency (unit: Hz)
% (2) dura: stimulus duration (unit: sec)
% (3) width: pulse width (unit: sec)
% (4) fs: sampling frequency (unit: Hz)
% (5) plotOption: plot or not (true/false)
% Written by Hio-Been Han, Jeelab, KIST, hiobeen@yonsei.ac.kr, 20170415

if nargin < 5
    plotOption = 0; end

train = zeros( [total_length, 1] );

lencycle = round(fs*(1/frq));
onIdx = 1:lencycle:total_length;
temp_outL = train ;
for ind = onIdx
    temp_outL(ind:ind+round((width*fs))) = 1;
end

train = temp_outL(1:total_length);
train(end)=0;

t = (1:length(train))/fs;

if plotOption
%     figure; 
    plot(t*1000, train, 'ko-');
    xlabel('Time (msec)'); ylabel('v'); axis tight;
    axiss=axis;
    axis([axiss(1)-100 axiss(2)+100 axiss(3)-.1 axiss(4)+.1]);
end
end