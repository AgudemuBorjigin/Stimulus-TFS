function [Env_sum, Tfs_sum] = EnvTFS(in, noiseCarrier, CF, fs)
% note: make sure the number of rows of the input signal equals the number
% of elements in CF

out = hilbert(in); % this funciton gives the analytic signal, notice the direction of the filtfilt operation
Env = abs(out);
envCutoff = 300;  % Biran C. J. Moore, Christian Lorenzi 2006: 64 Hz LPF % Qin and Oxenham 2003: 300 Hz LPF
[b, a] = butter(2, envCutoff/(fs/2)); 
Env = filtfilt(b, a, Env')'; % notice the direction of the filtfilt operation

% % rectification and low pass
% Env = max(0,in); % rectification
% nf = fs/2;
% fLow = 60; % fixed cutoff frequency
% [b,a] = butter(2,fLow/nf,'low');
% Env = filtfilt(b,a,Env')';

% tone carrier
% t= 0:1/fs:length(in(1,:))/fs-1/fs;
% for i = 1:numel(CF)
%     Env(i,:) = Env(i,:).*sin(2*pi*CF(i)*t+2*pi*rand); % The filtered env is used to AM the pure tone
%     % with a ferquency equal to the center fequency of the band, Biran C. J. Moore, Christian Lorenzi 2006
%     % , and with random starting phase
% end
% Env_sum = sum(Env); % summing across all freqeuncy bands

% band-limited noise carrier
% [noiseCarr] = BPFbank(rand(1,length(Env(1,:))),fs,CF);
% for i = 1:numel(CF)
%     Env(i,:) = Env(i,:).*noiseCarr(i,:);
% end
% Env_sum = sum(Env); % summing across all freqeuncy bands

% broadband noise carrier
noise = rand(1,length(Env(1,:)));
for i = 1:numel(CF)
    Env(i,:) = Env(i,:).*noiseCarrier;
    Env(i,:) = BPFbank(Env(i,:),fs,CF(i));
end
Env_sum = sum(Env); % summing across all freqeuncy bands


Tfs = cos(angle(out));

% for i = 1:numel(CF)
%     in_1chan = in(i,:);
%     Tfs_1chan = Tfs(i,:);
%     for j = 1:numel(in_1chan)
%         if abs(in_1chan(j)) < 0.5e-3
%             Tfs_1chan(j) = 0;
%         end
%     end
%     Tfs(i,:) = Tfs_1chan;
% end

for i = 1:numel(CF)
    Tfs(i,:) = Tfs(i,:)*rms(in(i, :)); % the tfs in each band is multiplied by the rms power
    % of the bandpass filtered signal
end
Tfs_sum = sum(Tfs); % summing across all frequency bands

end