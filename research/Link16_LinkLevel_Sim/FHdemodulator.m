function rcvBBmat = FHdemodulator(rcvNoisyMat, txFHtable, fs)
% Frequency-hopping demodulator function
% Input parameters:
%   rcvNoisyMat: Received noisy frequency-hopped signal matrix
%   txFHtable: Frequency-hop table
%   fs: Sampling rate
% Output parameters:
%   rcvBBmat: Dehopped baseband matrix

% Get hop count and samples per hop
[HOP_NUM, samplesPerHop] = size(rcvNoisyMat);

% Initialize output matrix
rcvBBmat = zeros(HOP_NUM, samplesPerHop);

% Process each hop
for hop = 1:HOP_NUM
    % Get current hop frequency
    freq = txFHtable(hop);
    
    % Get received signal of current hop
    received_signal = rcvNoisyMat(hop, :);
    
    % Generate time vector
    t = (0:samplesPerHop-1) / fs;
    
    % Downconvert to baseband
    carrier = exp(-1j * 2 * pi * freq * t);
    
    % Frequency-hop demodulation
    rcvBBmat(hop, :) = received_signal .* carrier;
    
    % Optional: add lowpass filter to suppress high-frequency components
    % rcvBBmat(hop, :) = lowpass(rcvBBmat(hop, :), cutoff_freq, fs);
end

end