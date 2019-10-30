[daHigh, ~] = audioread('da.wav');
[baHigh, ~] = audioread('ba.wav');
[baLow, ~] = audioread('ba3.wav');
[daLow, Fs] = audioread('da3.wav');

lens = zeros(1,4);
wavs = cell(1,4);
wavs{1} = daHigh'; wavs{2} = baHigh'; wavs{3} = baLow'; wavs{4} = daLow'; 


for i = 1:4
    lens(i) = length(wavs{i});
end

lenMax = max(lens);

for i = 1:4
    if lens(i) < lenMax
        wavs{i} = [wavs{i}, zeros(1,lenMax-lens(i))];
    end
end

daHigh = wavs{1}; baHigh = wavs{2}; baLow = wavs{3}; daLow = wavs{4};

save('badaSounds.mat', 'daHigh', 'baHigh','baLow','daLow');