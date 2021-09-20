fm = 40.8;
fs = 48828.125;
fc = 500;
ITD = 240e-6;
dur = 1.5;
t = 0:1/fs:dur-1/fs;
m = 1; % modulation depth
ramp = 0.05;

sin1 = sin(2*pi*fc*(t-ITD));
sin2 = sin(2*pi*fc*(t+ITD));
modr = 1+m*sin(2*pi*fm*t-pi/2);
carr1 = zeros(1,length(t));
carr2 = zeros(1,length(t));

for i = 1:length(t)
    if i >= fs*(1/fm)*floor((2/3)*dur/(1/fm)) % shift the phase between two ears
        % after around 2/3 of the the stimulus
        carr1(i) = sin1(i);
    else
        carr1(i) = sin2(i);
    end
end

for i = 1:length(t)
    if i >= fs*(1/fm)*floor((2/3)*dur/(1/fm))
        carr2(i) = sin2(i);
    else
        carr2(i) = sin1(i);
    end
end

for i = 1:length(t)
    if i >= fs*(1/fm)*floor((2/3)*dur/(1/fm))
        carr2(i) = sin2(i);
    else
        carr2(i) = sin1(i);
    end
end
right_TFS = modr.*carr1;
left_TFS = modr.*carr2;
right_TFS = rampsound(right_TFS, fs, ramp);
right_TFS = right_TFS/rms(right_TFS);
right_TFS = scaleSound(right_TFS);
left_TFS = rampsound(left_TFS, fs, ramp);
left_TFS = left_TFS/rms(left_TFS);
left_TFS = scaleSound(left_TFS);
out = [left_TFS;right_TFS];


index = fs*(1/fm)*floor((2/3)*dur/(1/fm));
plot(t(1:index),right_TFS(1:index),'r','LineWidth',2);
hold on;
plot(t(index+1:end),left_TFS(index+1:end),'b','LineWidth',2);

plot(t,right_TFS,'r','LineWidth',2);
hold on;
plot(t,left_TFS,'b','LineWidth',2);
hold on;
[envUpR, envLrR] = envelope(right_TFS, 30, 'peak');
[envUpL, envLrL] = envelope(left_TFS, 30, 'peak');
plot(t(1:floor(length(t)/2)), envUpL(1:floor(length(t)/2)), 'r', 'LineWidth',2);
hold on;
plot(t(1:floor(length(t)/2)), envLrR(1:floor(length(t)/2)), 'r', 'LineWidth',2);
hold on;
plot(t(floor(length(t)/2)+1:end), envUpL(floor(length(t)/2)+1:end), 'b', 'LineWidth',2);
hold on;
plot(t(floor(length(t)/2)+1:end), envLrR(floor(length(t)/2)+1:end), 'b', 'LineWidth',2);
% temporary
xticks(0.98);
xticklabels({'0.98'});
set(gca, 'xtick', []);
set(gca, 'ytick', []);
xlabel('Time [s]');
ylabel('Amplitude');
title('"Phase jump" in TFS');
legend('Right','Left');
set(gca,'Fontsize',40);