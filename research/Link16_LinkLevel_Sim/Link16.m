%% Link16 communication system simulation
% Version: v1.0.0
% Statistical bit-error-rate analysis of the frequency-hopping communication system
% Processing chain: modulation -> frequency hopping -> channel -> dehopping -> demodulation -> BER
tic
clc; clear; close all;

%% 1. System parameter configuration
% ===== 1.1 Feature switches =====
ENABLE_FH = 0;                  % 0: Frequency hopping disabled; 1: Enabled
MODULATION_TYPE = 4;            % 0: BPSK, 1: QPSK, 2: 16QAM, 3: 64QAM, 4: MSK
ENABLE_CRC = 0;                 % 0: CRC disabled; 1: Enabled
CODING_TYPE = 1;                % 0: No coding; 1: RS(31,15); 2: (2,1,7) convolutional coding
ENABLE_INTERLEAVING = 1;        % 0: Interleaving disabled; 1: Enabled
ENABLE_CCSK = 1;                % 0: CCSK spreading disabled; 1: Enabled

% ===== 1.2 Basic system parameters =====
bitRate = 5e4;                  % Bit rate: 50 kbps
samplesPerBit = 20;             % Oversampling factor
samplingRate = samplesPerBit * bitRate;  % Sampling rate: 1 MHz

% ===== 1.3 Frequency-hopping parameters =====
hoppingRate = 1000;             % Hopping rate: 1,000 hops/s
bitsPerHop = bitRate / hoppingRate;  % 50 bits per hop
frequencyBandwidth = 5e6;       % Frequency-hopping bandwidth: 5 MHz
frequencyPointCount = floor(frequencyBandwidth / (bitRate*4));  % Frequency points: 25
frequencyInterval = frequencyBandwidth / frequencyPointCount;  % Frequency spacing: 200 kHz
frequencySequence = ((0:frequencyPointCount-1) - floor(frequencyPointCount/2)) * frequencyInterval;  % Hop-frequency offsets relative to center
carrierFrequency = 300e6;       % Carrier center frequency: 300 MHz
carrierSequence = carrierFrequency + frequencySequence;  % Absolute hop-carrier frequencies

% ===== 1.4 Modulation parameters =====
switch MODULATION_TYPE
    case 0  % BPSK
        bitsPerSymbol = 1;      % BPSK: 1 bit per modulation symbol
        figureLabel_Modulation = 'BPSK';
    case 1  % QPSK
        bitsPerSymbol = 2;      % QPSK: 2 bits per modulation symbol
        figureLabel_Modulation = 'QPSK';
    case 2  % 16QAM
        bitsPerSymbol = 4;      % 16QAM: 4 bits per modulation symbol
        figureLabel_Modulation = '16QAM';
    case 3  % 64QAM
        bitsPerSymbol = 6;      % 64QAM: 6 bits per modulation symbol
        figureLabel_Modulation = '64QAM';
    case 4  % MSK
        bitsPerSymbol = 1;      % MSK: 1 bit per modulation symbol
        figureLabel_Modulation = 'MSK';
end
modulationOrder = 2^bitsPerSymbol;  % Modulation order: 2 raised to bits per symbol

% ===== 1.5 CRC parameters =====
if ENABLE_CRC == 1
    crcBlockSize = 225;         % CRC block length: append check bits per 225 data bits
    figureLabel_CRC = 'CRC(237,225)';  % 225 information bits + 12 CRC check bits
    polynomial = 'z12+1';       % CRC polynomial: z^12+1
else
    crcBlockSize = 1;           % Set to 1 when CRC disabled to avoid affecting calculation
    figureLabel_CRC = 'no CRC';
end

% ===== 1.6 Coding parameters =====
rs_m = 5;                       % Reed-Solomon symbol width: 5 bits
rs_n = 2^rs_m - 1;              % Reed-Solomon codeword length: 31 symbols (155 bits)
rs_t = 8;                       % Reed-Solomon correction capacity: up to 8 symbols
rs_k = rs_n - 2*rs_t;           % Reed-Solomon information length: 15 symbols (75 bits)

switch CODING_TYPE
    case 0  % No coding
        figureLabel_Coding = 'No error correction';
    case 1  % RS(31,15) coding
        figureLabel_Coding = 'RS(31,15) coding';
    case 2  % (2,1,7) convolutional coding
        figureLabel_Coding = '(2,1,7) convolutional coding';
        constraintLength = 7;   % Convolutional constraint length: 7
        tracebackDepth = 42;    % Viterbi traceback depth: 42 (6 times constraint length)
        trellis = poly2trellis(constraintLength, [171, 133]);  % Generator polynomials: 171 and 133 (octal)
end

% ===== 1.7 Interleaving parameters =====
if ENABLE_INTERLEAVING
    interleavingRows = 10;      % Interleaving matrix: 10 rows
    interleavingCols = 100;     % Interleaving matrix: 100 columns
    figureLabel_Interleaving = 'Interleaving enabled';
else
    figureLabel_Interleaving = 'Interleaving disabled';
end

% ===== 1.8 CCSK parameters =====
if ENABLE_CCSK == 1
    % Optimized 32-bit CCSK sequence (upstream description)
    ccskCode = [1 0 1 1 1 0 1 0 0 0 1 1 1 1 0 1 0 0 1 0 0 0 0 0 0 1 1 0 0 1 1 0]';
    figureLabel_CCSK = 'CCSK';
else
    figureLabel_CCSK = 'CCSK disabled';
end

% ===== 1.9 Message parameters =====
% Determine base message length accounting for RS coding and modulation requirements
messageLength = rs_m * rs_k;    % Base message length: 75 bits (one RS information block)
frameCount = 1;                 % Transmitted frame count: 1
packetCount = 3;                % Packets per frame: 3
bitsPerPacket = messageLength * bitsPerHop;  % Bits per packet: 75 x 50 = 3750
messageBitCount = bitsPerPacket * packetCount;  % Total message bits: 3750 x 3 = 11250
totalBitCount = messageBitCount;  % Total transmitted bits: 11250

% ===== 1.10 Frequency-hopping plot labels =====
if ENABLE_FH == 1
    figureLabel_FH = 'Frequency hopping enabled';
else
    figureLabel_FH = 'Frequency hopping disabled';
end

% ===== 1.11 MSK modulator/demodulator settings =====
if MODULATION_TYPE == 4  % MSK
    % The original built-in MATLAB MSK objects are commented out
    % mskModulator = comm.MSKModulator('BitInput', true, ...
    %                                 'SamplesPerSymbol', samplesPerBit, ...
    %                                 'InitialPhaseOffset', 0);
    % 
    % mskDemodulator = comm.MSKDemodulator('BitOutput', true, ...
    %                                     'SamplesPerSymbol', samplesPerBit, ...
    %                                     'InitialPhaseOffset', 0);
    
    % Use the custom MSK functions instead
    fprintf('Using custom MSK modulator and demodulator functions\n');
end

% ===== 1.12 Bit-error analysis parameters =====
snrValues = (-25:-15);            % Eb/No sweep: actual -25 through -15 dB; upstream comment claimed -10 through 0 dB
codeRate = 1/2;                 % Assumed overall code rate: 1/2 (coding and spreading)
berValues = zeros(1, length(snrValues));  % BER result array
packetErrorRate = zeros(1, length(snrValues));  % Packet-error-rate result array
crcErrorCount = zeros(1, length(snrValues));  % CRC error count

%% 2. Transmitter processing
% ===== 2.1 Generate transmit bit sequence =====
messageBits = randi([0, 1], 1, totalBitCount);  % Generate random binary message
inputBits = messageBits;        % Prepare transmit bit sequence

% ===== 2.2 CRC error detection coding =====
if ENABLE_CRC
    checksumPerFrame = length(inputBits)/crcBlockSize;  % Number of checksum blocks
    crcGenerator = comm.CRCGenerator(polynomial, 'ChecksumsPerFrame', checksumPerFrame);  % CRC generator
    crcDetector = comm.CRCDetector(polynomial, 'ChecksumsPerFrame', checksumPerFrame);  % CRC detector
    crcEncodedBits = crcGenerator(inputBits');  % CRC encode; input is column vector
    crcEncodedBits = crcEncodedBits';  % Convert back to row vector
else
    crcEncodedBits = inputBits;  % Bypass if CRC disabled
end

% ===== 2.3 Forward error correction =====
switch CODING_TYPE
    case 0  % No coding
        codedBits = crcEncodedBits;
    case 1  % RS coding
        codewordLength = rs_n;  % RS codeword length: 31 symbols
        messageLength = rs_k;   % RS message length: 15 symbols
        codedBits = RSEncoder(crcEncodedBits, codewordLength, messageLength);  % RS encoding
    case 2  % Convolutional coding
        codedBits = convenc(crcEncodedBits, trellis);  % Rate-1/2 convolutional coding
end

% ===== 2.4 Interleaving =====
if ENABLE_INTERLEAVING
    interleavingCount = length(codedBits)/(interleavingRows*interleavingCols);  % Interleaving block count
    interleavedBits = zeros(1, length(codedBits));

    for i = 1:interleavingCount
        startIdx = ((i-1)*(interleavingRows*interleavingCols))+1;
        endIdx = i*(interleavingRows*interleavingCols);
        tempData = codedBits(1, startIdx:endIdx);
        % Fill by columns, then read by rows for interleaving
        interleavedData = matintrlv(tempData, interleavingRows, interleavingCols);
        interleavedBits(1:i*interleavingRows*interleavingCols) = ...
            horzcat(interleavedBits(1:(i-1)*interleavingRows*interleavingCols), interleavedData);
    end
else
    interleavedBits = codedBits;  % Pass through when interleaving disabled
end

% ===== 2.5 CCSK spreading =====
if ENABLE_CCSK == 1
    spreadBits = CCSKModulator(interleavedBits, ccskCode);  % CCSK spreading: 1 bit to 32 bits
else
    spreadBits = interleavedBits;  % Pass through when CCSK disabled
end

%% 3. Bit-error-rate analysis
for snrIndex = 1:numel(snrValues)
    totalErrorBits = 0;
    totalErrorPackets = 0;
    % Convert Eb/No to SNR accounting for modulation efficiency and code rate
    snrDb = snrValues(snrIndex) + 10*log10(log2(modulationOrder)*codeRate);

    for frameIndex = 1:frameCount
        % ===== 3.1 Modulation =====
        switch MODULATION_TYPE
            case {0, 1, 2, 3}  % BPSK, QPSK, 16QAM, 64QAM
                % Map bits to modulation symbols
                symbolBits = reshape(spreadBits, log2(modulationOrder), [])';  % Group bits by modulation order
                symbolIndices = bi2de(symbolBits, 'left-msb');  % Convert binary to symbol indices
                
                % Baseband modulation
                if MODULATION_TYPE <= 1  % BPSK or QPSK
                    baseModulatedSignal = pskmod(symbolIndices, modulationOrder, pi/modulationOrder);
                else  % 16QAM or 64QAM
                    baseModulatedSignal = qammod(symbolIndices, modulationOrder, 'UnitAveragePower', true);
                end
                
                % Upsampling
                modulatedSignal = upsample(baseModulatedSignal, samplesPerBit);
                
                % Optional pulse-shaping filter
                % span = 6;
                % rolloff = 0.25;
                % rrcFilter = rcosdesign(rolloff, span, samplesPerBit);
                % modulatedSignal = filter(rrcFilter, 1, modulatedSignal);
                
            case 4  % MSK
                % First determine the number of hops
                % Compute bits per hop
                bitsPerHop = bitRate / hoppingRate;  % 50 bits per hop
                
                % Calculate required number of hops
                totalBits = length(spreadBits);
                hopCount = ceil(totalBits / bitsPerHop);
                
                % Reshape bit stream into matrix (one hop per row)
                % Zero-pad if the final hop does not contain enough bits
                paddingBits = hopCount * bitsPerHop - totalBits;
                paddedBits = [spreadBits, zeros(1, paddingBits)];
                bitsMatrix = reshape(paddedBits, bitsPerHop, hopCount)';  % Rows = hops; columns = bits
                
                % Use custom MSK modulator
                [~, modulatedSignalMatrix] = MSKmodulator(samplesPerBit, bitsMatrix);
                
                % Normalize power
                for hop = 1:hopCount
                    modulatedSignalMatrix(hop, :) = modulatedSignalMatrix(hop, :) / sqrt(mean(abs(modulatedSignalMatrix(hop, :)).^2));
                end
                
                % Flatten matrix to a vector for consistency with other modulation modes
                modulatedSignal = reshape(modulatedSignalMatrix', [], 1);
        end
        
        % Normalize power
        modulatedSignal = modulatedSignal / sqrt(mean(abs(modulatedSignal).^2));
        
        % ===== 3.2 Zero-padding alignment =====
        if MODULATION_TYPE == 4  % MSK
            % MSK padding already handled during modulation; record padding count
            exceedBitCount = paddingBits;
            % modulatedSignalMatrix already exists; do not recreate it
        else
            % Original zero-padding alignment code
            hopCount = ceil(length(modulatedSignal) / (samplesPerBit*bitsPerHop));  % Determine number of hops
            paddingSampleCount = hopCount * samplesPerBit * bitsPerHop - length(modulatedSignal);
            modulatedSignal = [modulatedSignal; zeros(paddingSampleCount, 1)];  % Zero-pad signal at end
            
            % Save padding count for removal during demodulation
            exceedBitCount = paddingSampleCount;
            % Reshape signal into a matrix (one hop per row)
            modulatedSignalMatrix = reshape(modulatedSignal, samplesPerBit*bitsPerHop, hopCount);
            modulatedSignalMatrix = modulatedSignalMatrix.';  % Transpose: rows = hops, columns = samples
        end
        
        % ===== 3.3 Frequency hopping and channel transmission =====
        if ENABLE_FH == 0
            % No hopping: transmit baseband signal directly
            transmittedSignal = reshape(modulatedSignalMatrix.', numel(modulatedSignalMatrix), 1);
            receivedNoisy = awgn(transmittedSignal, snrDb);  % Add white Gaussian noise
            receivedNoisyMatrix = reshape(receivedNoisy, numel(receivedNoisy) / hopCount, hopCount);
            receivedBasebandMatrix = receivedNoisyMatrix.';
        else
            % Hopping: generate random frequency-hop sequence
            frequencyHoppingIndices = randi([1, frequencyPointCount], 1, hopCount);
            transmitFrequencyTable = carrierSequence(frequencyHoppingIndices);
            % Frequency-hop modulation
            frequencyHoppedSignalMatrix = FHmodulator(modulatedSignalMatrix, transmitFrequencyTable, samplingRate);

            % Channel transmission
            transmittedSignal = reshape(frequencyHoppedSignalMatrix.', 1, numel(frequencyHoppedSignalMatrix));
            receivedNoisy = awgn(transmittedSignal, snrDb);  % Add white Gaussian noise

            % Reshape into a matrix
            receivedNoisyMatrix = reshape(receivedNoisy, samplesPerBit*bitsPerHop, hopCount);
            receivedNoisyMatrix = receivedNoisyMatrix.';  % Rows = hops, columns = samples

            % Frequency-hop demodulation
            receivedBasebandMatrix = FHdemodulator(receivedNoisyMatrix, transmitFrequencyTable, samplingRate);
        end

        % ===== 3.4 Demodulation =====
        receivedBasebandSignal = reshape(receivedBasebandMatrix.', 1, numel(receivedBasebandMatrix));

        % Use appropriate processing for selected modulation mode
        if MODULATION_TYPE == 4  % MSK
            % Use custom MSK demodulator
            demodulatedBitStream = [];
            for hop = 1:hopCount
                hopBits = MSKdemodulator(samplesPerBit, receivedBasebandMatrix(hop, :));
                demodulatedBitStream = [demodulatedBitStream, hopBits];
            end
            
            % Remove padded bits
            if exceedBitCount > 0
                demodulatedBitStream = demodulatedBitStream(1:end-exceedBitCount);
            end
        else
            % Demodulation path for other modulation modes
            % Remove padded samples
            if exceedBitCount > 0
                receivedData = receivedBasebandSignal(1:end-exceedBitCount);
            else
                receivedData = receivedBasebandSignal;
            end
            
            % Convert to column vector
            receivedSignal = reshape(receivedData, [], 1);
            
            % Downsample
            downsampled = receivedSignal(1:samplesPerBit:end);
            
            % Demodulate
            if MODULATION_TYPE <= 1  % BPSK or QPSK
                demodulatedIndices = pskdemod(downsampled, modulationOrder, pi/modulationOrder);
            else  % 16QAM or 64QAM
                demodulatedIndices = qamdemod(downsampled, modulationOrder, 'UnitAveragePower', true);
            end
            
            % Convert symbols back to bits
            demodulatedBits = de2bi(demodulatedIndices, log2(modulationOrder), 'left-msb');
            demodulatedBitStream = reshape(demodulatedBits', 1, []);
        end

        %% Despreading
        if ENABLE_CCSK == 1
            ccsk_dec = CCSKDemodulator(demodulatedBitStream, ccskCode);  % CCSK despreading
        else
            ccsk_dec = double(demodulatedBitStream);  % Pass through if CCSK disabled
        end

        %% Deinterleaving
        if ENABLE_INTERLEAVING == 1
            deinterleavedBits = zeros(1, length(ccsk_dec));
            for k = 1:interleavingCount
                startIdx = ((k-1)*(interleavingRows*interleavingCols))+1;
                endIdx = k*(interleavingRows*interleavingCols);
                tempData = ccsk_dec(1, startIdx:endIdx);
                % Fill by rows, then read by columns for deinterleaving
                deinterleavedData = matdeintrlv(tempData, interleavingRows, interleavingCols);
                deinterleavedBits(1:k*interleavingRows*interleavingCols) = ...
                    horzcat(deinterleavedBits(1:(k-1)*interleavingRows*interleavingCols), deinterleavedData);
            end
        else
            deinterleavedBits = ccsk_dec;  % Pass through if interleaving disabled
        end

        %% Channel decoding
        switch CODING_TYPE
            case 0  % No coding
                decodedBits = deinterleavedBits;
            case 1  % RS decoding
                decodedBits = RSDecoder(deinterleavedBits, codewordLength, messageLength);
            case 2  % Convolutional decoding
                decodedBits = vitdec(deinterleavedBits, trellis, tracebackDepth, 'trunc', 'hard');  % Hard-decision Viterbi decoding
        end

        %% CRC error detection
        if ENABLE_CRC == 1
            [decodedData, crcError] = crcDetector(decodedBits');  % CRC check; input is column vector
            crcErrorCount(snrIndex) = crcErrorCount(snrIndex) + sum(crcError);
            decodedData = decodedData';  % Convert back to row vector
        else
            decodedData = decodedBits;  % Pass through if CRC disabled
        end

        % Count erroneous bits
        % Ensure compared vectors have matching lengths
        minLength = min(length(inputBits), length(decodedData));
        errorBits = sum(inputBits(1:minLength) ~= decodedData(1:minLength));
        totalErrorBits = totalErrorBits + errorBits;

        % Calculate packet error rate
        originalPacket = inputBits;
        decodedPacket = decodedData;
        originalPacketMatrix = reshape(originalPacket, messageBitCount/packetCount, packetCount);
        decodedPacketMatrix = reshape(decodedPacket, messageBitCount/packetCount, packetCount);
        packetErrors = sum(bsxfun(@ne, originalPacketMatrix, decodedPacketMatrix), 1) > 0;
        totalErrorPackets = totalErrorPackets + sum(packetErrors);
    end

    % Calculate bit and packet error rates
    berValues(snrIndex) = totalErrorBits / (frameCount * totalBitCount);
    packetErrorRate(snrIndex) = totalErrorPackets / (frameCount * packetCount);
end

%% Error-rate performance analysis
figure
semilogy(snrValues, berValues, '-*')
save MSK+RS+CCSK+FH berValues
hold on
grid on

xlabel('Eb/No (dB)')  % X axis: energy per bit to noise spectral-density ratio
ylabel('Bit error rate')     % Y axis: bit-error rate (BER)
title(['Link16 simulation performance: ', figureLabel_Modulation, ' + ', figureLabel_Coding, ' + ', figureLabel_CCSK, ' + ', figureLabel_FH]);

toc
