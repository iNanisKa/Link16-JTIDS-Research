function ccsk_dec = CCSKDemodulator(dmdBit, ccskcode)
% CCSK despreading function
% Input parameters:
%   dmdBit: Input spread binary data
%   ccskcode: CCSK sequence (32 bits)
% Output parameters:
%   ccsk_dec: Despread binary data

% CCSK sequence length
n_ccsk = length(ccskcode);

% Calculate number of symbols in the input
num_symbols = floor(length(dmdBit) / n_ccsk);

% Initialize despread data
ccsk_dec = zeros(1, num_symbols);

% Generate cyclically shifted CCSK sequence for comparison
shifted_code = [ccskcode(end); ccskcode(1:end-1)];

% Despread each CCSK symbol
for i = 1:num_symbols
    % Extract current CCSK symbol
    start_idx = (i-1) * n_ccsk + 1;
    end_idx = i * n_ccsk;
    current_symbol = dmdBit(start_idx:end_idx);
    
    % Calculate correlation with original CCSK sequence
    corr_original = sum(current_symbol == ccskcode');
    
    % Calculate correlation with shifted CCSK sequence
    corr_shifted = sum(current_symbol == shifted_code');
    
    % Estimate original bit based on correlation
    if corr_shifted > corr_original
        ccsk_dec(i) = 1;
    else
        ccsk_dec(i) = 0;
    end
end
end
