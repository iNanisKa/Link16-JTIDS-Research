function ccsk_msg = CCSKModulator(interwine_msg, ccskcode)
% CCSK spreading function
% Input parameters:
%   interwine_msg: Input binary data
%   ccskcode: CCSK sequence (32 bits)
% Output parameters:
%   ccsk_msg: Spread binary data

% Initialize spread message
ccsk_msg = [];

% CCSK sequence length
n_ccsk = length(ccskcode);

% Process each input bit
for i = 1:length(interwine_msg)
    if interwine_msg(i) == 0
        % If input bit is zero, use original CCSK sequence
        spread_bits = ccskcode';
    else
        % If input bit is one, use cyclically shifted CCSK sequence
        % Upstream example uses a one-bit cyclic right shift
        shifted_code = [ccskcode(end); ccskcode(1:end-1)];
        spread_bits = shifted_code';
    end
    
    % Append to spread message
    ccsk_msg = [ccsk_msg, spread_bits];
end

end
