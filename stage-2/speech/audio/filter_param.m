function b = filter_param(num_trial, gender, root, fs)
for i = 1:num_trial
    load(strcat(root, 'trial', int2str(num_trial), '.mat'));
    tar_abs{i} = abs(fft(stim_tar)); %#ok<AGROW>
    if gender(1) == 's'
        bck_abs{i} = abs(fft(stim_same)); %#ok<AGROW>
    else
        bck_abs{i} = abs(fft(stim_opposite)); %#ok<AGROW>
    end
    
    if i == 1
        tar_abs_avg = tar_abs{i};
        bck_abs_avg = bck_abs{i};
    else
        if length(tar_abs{i}) < length(tar_abs_avg)
            tar_abs_avg = tar_abs_avg + [tar_abs{i}; zeros(length(tar_abs_avg) - length(tar_abs{i}), 1)];
        else
            tar_abs_avg = tar_abs{i} + [tar_abs_avg; zeros(length(tar_abs{i}) - length(tar_abs_avg), 1)];
        end
        if length(bck_abs{i}) < length(bck_abs_avg)
            bck_abs_avg = bck_abs_avg + [bck_abs{i}; zeros(length(bck_abs_avg) - length(bck_abs{i}), 1)];
        else
            bck_abs_avg = bck_abs{i} + [bck_abs_avg; zeros(length(bck_abs{i}) - length(bck_abs_avg), 1)];
        end
    end
end

tar_abs_avg = tar_abs_avg/num_trial;
bck_abs_avg = bck_abs_avg/num_trial;

if length(tar_abs_avg) < length(bck_abs_avg)
    tar_abs_avg = [tar_abs_avg; zeros(length(bck_abs_avg) - length(tar_abs_avg), 1)];
else
    bck_abs_avg = [bck_abs_avg; zeros(length(tar_abs_avg) - length(bck_abs_avg), 1)];
end

% gain/ratio between target and background
gain = tar_abs_avg./bck_abs_avg;

% generation of fitler parameter according to the gain 
f = (0:(numel(gain) - 1))*fs/numel(gain);
f_half = f(f< fs/2);
f_half = f_half';
gain_half = gain(f<fs/2);
b = fir2(128, f_half/max(f_half), gain_half); % smaller the filter order, smoother the filter
end