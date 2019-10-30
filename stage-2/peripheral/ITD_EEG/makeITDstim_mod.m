function [out] = makeITDstim_mod(rightOrLeft, ITD, fc, fs, fm, duration, ramp, TFSorENV)
m = 1; % modulation depth
t = 0:1/fs:duration-1/fs;

if strcmp(rightOrLeft, 'right')
    sig = makeITDstim_freqdomain(ITD, 0, fc, fs, duration);
elseif strcmp(rightOrLeft, 'left')
    sig = makeITDstim_freqdomain(ITD, 1, fc, fs, duration);
else
    fprintf(2, 'Unrecognized structure type! Try again! (Choose from right or left)');
end

ITD = ITD/2; % So that the jump is IPD

if TFSorENV == 'TFS'
    %% ITD in TFS(carrier)
    sin1 = sig(1, :);
    sin2 = sig(2, :);
    modr = 1+m*sin(2*pi*fm*t-pi/2);
    
    carr1 = zeros(1,length(t));
    carr2 = zeros(1,length(t));
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm)) % shift the phase between two ears
            % after around 2/3 of the the stimulus
            carr1(i) = sin2(i);
        else
            carr1(i) = sin1(i);
        end
    end
    
    for i = 1:length(t)
        if i >= fs*(1/fm)*floor((2/3)*duration/(1/fm))
            carr2(i) = sin1(i);
        else
            carr2(i) = sin2(i);
        end
    end
    right_TFS = modr.*carr2;
    left_TFS = modr.*carr1;
    right_TFS = rampsound(right_TFS, fs, ramp);
    right_TFS = right_TFS/rms(right_TFS);
    right_TFS = scaleSound(right_TFS);
    left_TFS = rampsound(left_TFS, fs, ramp);
    left_TFS = left_TFS/rms(left_TFS);
    left_TFS = scaleSound(left_TFS);
    out = [left_TFS;right_TFS];
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
