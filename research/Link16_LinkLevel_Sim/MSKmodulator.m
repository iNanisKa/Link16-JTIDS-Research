function [biNRZ, txSig] = MSKmodulator(samp, TX_BIT_MAT)
% MSK modulator function
% Input parameters:
%   samp: Oversampling factor
%   TX_BIT_MAT: Input binary matrix, one hop per row
% Output parameters:
%   biNRZ: Bipolar NRZ signal
%   txSig: MSK-modulated signal

% Get matrix dimensions
[num_hops, bits_per_hop] = size(TX_BIT_MAT);

% Initialize output
biNRZ = zeros(num_hops, bits_per_hop);
txSig = zeros(num_hops, samp * bits_per_hop);

% MSK parameters
h = 0.5;  % Modulation index; MSK uses 0.5

for hop = 1:num_hops
    % Get bits for current hop
    bits = TX_BIT_MAT(hop, :);
    
    % Convert to bipolar NRZ (0->-1, 1->1)
    biNRZ(hop, :) = 2 * bits - 1;
    
    % Initialize I and Q components
    I_phase = zeros(1, samp * bits_per_hop);
    Q_phase = zeros(1, samp * bits_per_hop);
    
    % Generate I and Q component phases
    for i = 1:bits_per_hop
        bit_idx = (i-1)*samp+1:i*samp;
        t = (0:samp-1) / samp;
        
        if mod(i, 2) == 1  % Odd-numbered bits affect I component
            I_phase(bit_idx) = biNRZ(hop, i) * cos(pi*t/2);
        else  % Even-numbered bits affect Q component
            Q_phase(bit_idx) = biNRZ(hop, i) * sin(pi*t/2);
        end
    end
    
    % Generate carriers
    t_full = (0:samp*bits_per_hop-1)/samp;
    carrier_I = cos(2*pi*0.25*t_full);
    carrier_Q = sin(2*pi*0.25*t_full);
    
    % Modulation
    I_signal = I_phase .* carrier_I;
    Q_signal = Q_phase .* carrier_Q;
    
    % Complex signal representation
    txSig(hop, :) = I_signal + 1j * Q_signal;
end

end


