%% MSK modulation/demodulation test script
clc; clear; close all;

%% Parameter settings
samp = 20;                % Oversampling factor
bitCount = 1000;          % Test bit count
snrValues = -10:2:10;     % Test SNR range

%% Generate random test data
txBits = randi([0, 1], 1, bitCount);

%% Single-hop test
TX_BIT_MAT = txBits;      % Use bit sequence directly for one hop

%% MSK modulation
[biNRZ, txSig] = MSKmodulator(samp, TX_BIT_MAT);

%% Test across SNR values
berValues = zeros(1, length(snrValues));

for i = 1:length(snrValues)
    snr = snrValues(i);
    
    % Add noise
    rxSig = awgn(txSig, snr);
    
    % MSK demodulation
    demodBits = MSKdemodulator(samp, rxSig);
    
    % Calculate bit error rate
    errors = sum(txBits ~= demodBits(1:length(txBits)));
    berValues(i) = errors / bitCount;
    
    % Display progress
    fprintf('SNR = %d dB, BER = %.6f\n', snr, berValues(i));
end

%% Plot BER curve
figure;
semilogy(snrValues, berValues, '-o', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit error rate (BER)');
title('MSK modulation/demodulation performance test');

%% Theoretical MSK BER curve
theoreticalBer = 0.5 * erfc(sqrt(10.^(snrValues/10)/2));
hold on;
semilogy(snrValues, theoreticalBer, '--r', 'LineWidth', 2);
legend('Measured performance', 'Theoretical MSK performance');

%% Waveform visualization test
% Select short segment for visualization
visualBits = txBits(1:20);
[~, visualTxSig] = MSKmodulator(samp, visualBits);

% Demodulation
visualDemodBits = MSKdemodulator(samp, visualTxSig);

% Plot original bits, modulated signal and demodulated bits
figure;
subplot(3,1,1);
stem(visualBits, 'filled');
title('Original bit sequence');
ylim([-0.2, 1.2]);
grid on;

subplot(3,1,2);
t = (0:length(visualTxSig)-1)/samp;
plot(t, real(visualTxSig), 'b-', t, imag(visualTxSig), 'r-');
title('MSK-modulated signal');
legend('I component', 'Q component');
grid on;

subplot(3,1,3);
stem(visualDemodBits(1:length(visualBits)), 'filled');
title('Demodulated bit sequence');
ylim([-0.2, 1.2]);
grid on;

%% Multiple-hop test
hopCount = 5;
bitsPerHop = 200;
TX_BIT_MAT_MULTI = randi([0, 1], hopCount, bitsPerHop);

% MSK modulation
[biNRZ_multi, txSig_multi] = MSKmodulator(samp, TX_BIT_MAT_MULTI);

% Demodulation without noise
for hop = 1:hopCount
    rxSig_hop = txSig_multi(hop, :);
    demodBits_hop = MSKdemodulator(samp, rxSig_hop);
    
    % Calculate BER for each hop
    errors = sum(TX_BIT_MAT_MULTI(hop, :) ~= demodBits_hop(1:bitsPerHop));
    fprintf('Hop %d: BER = %.6f\n', hop, errors/bitsPerHop);
end

%% Phase continuity test
% Generate continuous bit sequence
contBits = randi([0, 1], 1, 50);
[~, contTxSig] = MSKmodulator(samp, contBits);

% Plot phase continuity
figure;
t = (0:length(contTxSig)-1)/samp;
plot(t, angle(contTxSig));
title('MSK phase continuity');
xlabel('Time (bit periods)');
ylabel('Phase (radians)');
grid on;