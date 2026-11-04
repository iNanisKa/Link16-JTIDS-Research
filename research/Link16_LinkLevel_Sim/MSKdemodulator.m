function [demodBits] = MSKdemodulator(samp, rxSig)
% MSK demodulator function
% Input parameters:
%   samp: Oversampling factor
%   rxSig: Received MSK-modulated signal
% Output parameters:
%   demodBits: Demodulated binary data

% Ensure rxSig is a row vector
rxSig = rxSig(:)';

% Calculate signal length and bit count
sigLen = length(rxSig);
bitCount = floor(sigLen / samp);

% Initialize output
demodBits = zeros(1, bitCount);

% Extract I and Q components
I_signal = real(rxSig);
Q_signal = imag(rxSig);

% Generate local carriers
t_full = (0:sigLen-1) / samp;
carrier_I = cos(2*pi*0.25*t_full);
carrier_Q = sin(2*pi*0.25*t_full);

% Downconversion
I_baseband = I_signal .* carrier_I;
Q_baseband = Q_signal .* carrier_Q;

% Process each bit
for i = 1:bitCount
    % Calculate sample indices for current bit
    bit_idx = (i-1)*samp+1:i*samp;
    t_bit = (0:samp-1) / samp;
    
    if mod(i, 2) == 1  % Odd-numbered bit affects I component
        % Correlate with cosine waveform
        I_bit = I_baseband(bit_idx);
        corr_value = sum(I_bit .* cos(pi*t_bit/2));
        demodBits(i) = corr_value > 0;
    else  % Even-numbered bit affects Q component
        % Correlate with sine waveform
        Q_bit = Q_baseband(bit_idx);
        corr_value = sum(Q_bit .* sin(pi*t_bit/2));
        % Revision: invert even-bit decision condition
        demodBits(i) = corr_value < 0;  % Note: condition changed to < 0
    end
end

end


