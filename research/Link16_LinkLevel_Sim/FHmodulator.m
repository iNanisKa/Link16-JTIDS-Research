function txFHmodulatedMat = FHmodulator(msgModMatrix, txFHtable, fs)
% Frequency-hopping modulator function
% Input parameters:
%   msgModMatrix: Modulated signal matrix, one row per hop
%   txFHtable: Frequency-hop table
%   fs: Sampling rate
% Output parameters:
%   txFHmodulatedMat: Frequency-hopped signal matrix

% Get hop count and samples per hop
[HOP_NUM, samplesPerHop] = size(msgModMatrix);

% Initialize output matrix
txFHmodulatedMat = zeros(HOP_NUM, samplesPerHop);

% Process each hop
for hop = 1:HOP_NUM
    % Get current hop frequency
    freq = txFHtable(hop);
    
    % Get current hop baseband signal
    baseband_signal = msgModMatrix(hop, :);
    
    % Generate time vector
    t = (0:samplesPerHop-1) / fs;
    
    % Upconvert to selected frequency
    carrier = exp(1j * 2 * pi * freq * t);
    
    % Frequency-hop modulation
    txFHmodulatedMat(hop, :) = baseband_signal .* carrier;
end

end