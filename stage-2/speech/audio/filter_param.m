function b = filter_param(num_trial, count, gender, root)
for i = 1:num_trial
    load(strcat(root, 'trial', int2str(count+num_trial), '.mat'));
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
        [tar_abs{i}, tar_abs_avg] = zeroPadding(tar_abs{i}, tar_abs_avg); %#ok<AGROW>
        
        [bck_abs{i}, bck_abs_avg] = zeroPadding(bck_abs{i}, bck_abs_avg); %#ok<AGROW>
    end
end

tar_abs_avg = tar_abs_avg/num_trial;
bck_abs_avg = bck_abs_avg/num_trial;

[tar_abs_avg, bck_abs_avg] = zeroPadding(tar_abs_avg, bck_abs_avg);

% gain/ratio between target and background
gain = tar_abs_avg./bck_abs_avg;

% generation of fitler parameter according to the gain 
f = (0:(numel(gain) - 1))*fs/numel(gain);
f_half = f(f< fs/2);
f_half = f_half';
gain_half = gain(f<fs/2);
b = fir2(128, f_half/max(f_half), gain_half); % smaller the filter order, smoother the filter
end