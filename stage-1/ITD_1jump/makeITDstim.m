function [out] = makeITDstim(rightOrLeft, ITD, fc, fs, fm, duration, ramp, TFSorENV)
% fc = 520; % carrier frequency
% fc = 4e3;
% fm = 40.8; % modulation frequency
m = 1; % modulation depth
t = 0:1/fs:duration-1/fs;

if strcmp(rightOrLeft, 'right')
    
elseif strcmp(rightOrLeft, 'left')
    ITD = -ITD;
else
    fprintf(2, 'Unrecognized structure type! Try again! (Choose from right or left)');
end

ITD = ITD/2; % So that the jump is IPD
if TFSorENV == 'TFS'
    %% ITD in TFS(carrier)
    sin1 = sin(2*pi*fc*(t-ITD));
    sin2 = sin(2*pi*fc*(t+ITD));
    modr = 1+m*sin(2*pi*fm*t-pi/2);
    
    carr1 = zeros(1,length(t));
    carr2 = zeros(1,length(t));
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm)) % shift the phase between two ears
            % after around 2/3 of the the stimulus
            carr1(i) = sin1(i);
        else
            carr1(i) = sin2(i);
        end
    end
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm))
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
    
    
%     index = fs*(1/fm)*floor((2/3)*duration/(1/fm));
%     plot(t(1:index),right_TFS(1:index),'r','LineWidth',2);
%     hold on;
%     plot(t(index+1:end),left_TFS(index+1:end),'b','LineWidth',2);

%     plot(t,right_TFS,'r','LineWidth',2);
%     hold on;
%     plot(t,left_TFS,'b','LineWidth',2);
%     hold on;
%     [envUpR, envLrR] = envelope(right_TFS, 30, 'peak');
%     [envUpL, envLrL] = envelope(left_TFS, 30, 'peak');
%     plot(t(1:floor(length(t)/2)), envUpL(1:floor(length(t)/2)), 'r', 'LineWidth',2);
%     hold on;
%     plot(t(1:floor(length(t)/2)), envLrR(1:floor(length(t)/2)), 'r', 'LineWidth',2);
%     hold on;
%     plot(t(floor(length(t)/2)+1:end), envUpL(floor(length(t)/2)+1:end), 'b', 'LineWidth',2);
%     hold on;
%     plot(t(floor(length(t)/2)+1:end), envLrR(floor(length(t)/2)+1:end), 'b', 'LineWidth',2);
%     % temporary
%     xticks([0.0245]);
%     xticklabels({'0.9804'});
%     set(gca, 'xtick', []);
%     set(gca, 'ytick', []);
%     xlabel('Time [s]');
%     ylabel('Amplitude');
%     title('"Phase jump" in TFS');
%     legend('Right','Left');
%     set(gca,'Fontsize',12);
elseif TFSorENV == 'ENV'
    %% ITD in Env
    m1 = 1+m*sin(2*pi*fm*(t-ITD)-pi/2);
    m2 = 1+m*sin(2*pi*fm*(t+ITD)-pi/2);
    carr = sin(2*pi*fc*t);
    modr1 = zeros(1,length(t));
    modr2 = zeros(1,length(t));
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm))
            modr1(i) = m1(i);
        else
            modr1(i) = m2(i);
        end
    end
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm))
            modr2(i) = m2(i);
        else
            modr2(i) = m1(i);
        end
    end
    right_Env = modr1.*carr;
    left_Env = modr2.*carr;
    right_Env = rampsound(right_Env, fs, ramp);
    right_Env = right_Env/rms(right_Env);
    right_Env = scaleSound(right_Env);
    left_Env = rampsound(left_Env, fs, ramp);
    left_Env = left_Env/rms(left_Env);
    left_Env = scaleSound(left_Env);
    out = [right_Env;left_Env];
    
    plot(t,right_Env,'r','LineWidth',2);
    hold on;
    plot(t,left_Env,'b','LineWidth',2);
    grid on;
    xlabel('Time [s]');
    ylabel('Amplitude');
    title('Phase jump in Env');
    legend('Right','Left');
    set(gca,'Fontsize',15);
else
    fprintf(2, 'Unrecognized structure type! Try again! (Choose from TFS and ENV for TFSorENV input parameter)');
end
end
