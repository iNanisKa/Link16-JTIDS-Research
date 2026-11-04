function encoded_msg = RSEncoder(dataIn_crc, nn, kk)
% Reed-Solomon encoding function
% Input parameters:
%   dataIn_crc: Input binary data
%   nn: Codeword length (message plus parity)
%   kk: Message length
% Output parameters:
%   encoded_msg: Encoded binary data

% Initialize encoded message
encoded_msg = [];

% Calculate bits per group
m = log2(nn + 1); % Bits per RS symbol
bits_per_group = m * kk;

% Process input in groups
num_groups = floor(length(dataIn_crc) / bits_per_group);

for i = 1:num_groups
    % Extract current group
    start_idx = (i-1) * bits_per_group + 1;
    end_idx = i * bits_per_group;
    group_data = dataIn_crc(start_idx:end_idx);
    
    % Convert binary data to symbols in GF(2^m)
    gf_symbols = zeros(1, kk);
    for j = 1:kk
        bit_start = (j-1) * m + 1;
        bit_end = j * m;
        if bit_end <= length(group_data)
            symbol_bits = group_data(bit_start:bit_end);
            gf_symbols(j) = bi2de(symbol_bits, 'left-msb');
        end
    end
    
    % Create RS encoder and encode
    rs_encoder = comm.RSEncoder('CodewordLength', nn, 'MessageLength', kk);
    encoded_symbols = rs_encoder(gf_symbols');
    
    % Convert encoded symbols back to binary
    encoded_bits = [];
    for j = 1:nn
        symbol_dec = encoded_symbols(j);
        symbol_bits = de2bi(symbol_dec, m, 'left-msb');
        encoded_bits = [encoded_bits, symbol_bits];
    end
    
    % Append to encoded message
    encoded_msg = [encoded_msg, encoded_bits];
end
end
