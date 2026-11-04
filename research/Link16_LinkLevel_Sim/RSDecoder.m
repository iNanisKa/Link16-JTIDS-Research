function dataOut_dc = RSDecoder(deinterwine_data, nn, kk)
% Reed-Solomon decoding function
% Input parameters:
%   deinterwine_data: Input binary data
%   nn: Codeword length (message plus parity)
%   kk: Message length
% Output parameters:
%   dataOut_dc: Decoded binary data

% Initialize decoded message
dataOut_dc = [];

% Calculate bits per group
m = log2(nn + 1); % Bits per RS symbol
bits_per_codeword = m * nn;

% Process input in groups
num_codewords = floor(length(deinterwine_data) / bits_per_codeword);

for i = 1:num_codewords
    % Extract current codeword
    start_idx = (i-1) * bits_per_codeword + 1;
    end_idx = i * bits_per_codeword;
    codeword_bits = deinterwine_data(start_idx:end_idx);
    
    % Convert binary data to symbols in GF(2^m)
    gf_symbols = zeros(1, nn);
    for j = 1:nn
        bit_start = (j-1) * m + 1;
        bit_end = j * m;
        if bit_end <= length(codeword_bits)
            symbol_bits = codeword_bits(bit_start:bit_end);
            gf_symbols(j) = bi2de(symbol_bits, 'left-msb');
        end
    end
    
    % Create RS decoder and decode
    rs_decoder = comm.RSDecoder('CodewordLength', nn, 'MessageLength', kk);
    try
        % Use numeric data directly rather than gf objects
        decoded_symbols = rs_decoder(gf_symbols');
        
        % Convert decoded symbols back to binary
        decoded_bits = [];
        for j = 1:kk
            symbol_dec = decoded_symbols(j);
            symbol_bits = de2bi(symbol_dec, m, 'left-msb');
            decoded_bits = [decoded_bits, symbol_bits];
        end
    catch
        % If decoding fails, keep original information portion
        decoded_bits = codeword_bits(1:m*kk);
    end
    
    % Append to decoded message
    dataOut_dc = [dataOut_dc, decoded_bits];
end

% Process remaining bits
if length(deinterwine_data) > num_codewords * bits_per_codeword
    remaining_bits = deinterwine_data(num_codewords * bits_per_codeword + 1:end);
    dataOut_dc = [dataOut_dc, remaining_bits];
end

end
