%% MSK modulation/demodulation debugging script
clc; clear; close all;

%% Parameter settings
samp = 20;  % Oversampling factor

%% Single-bit test
fprintf('Testing single-bit modulation/demodulation...\n');

% Test bit 0
bit0 = [0];
[~, sig0] = MSKmodulator(samp, bit0);
demod0 = MSKdemodulator(samp, sig0);
fprintf('Bit 0 -> demodulated: %d (expected 0)\n', demod0);

% Test bit 1
bit1 = [1];
[~, sig1] = MSKmodulator(samp, bit1);
demod1 = MSKdemodulator(samp, sig1);
fprintf('Bit 1 -> demodulated: %d (expected 1)\n', demod1);

%% Two-bit test
fprintf('\nTesting two-bit modulation/demodulation...\n');

% Test 00
bits00 = [0 0];
[~, sig00] = MSKmodulator(samp, bits00);
demod00 = MSKdemodulator(samp, sig00);
fprintf('Bits 00 -> demodulated: %d%d (expected 00)\n', demod00(1), demod00(2));

% Test 01
bits01 = [0 1];
[~, sig01] = MSKmodulator(samp, bits01);
demod01 = MSKdemodulator(samp, sig01);
fprintf('Bits 01 -> demodulated: %d%d (expected 01)\n', demod01(1), demod01(2));

% Test 10
bits10 = [1 0];
[~, sig10] = MSKmodulator(samp, bits10);
demod10 = MSKdemodulator(samp, sig10);
fprintf('Bits 10 -> demodulated: %d%d (expected 10)\n', demod10(1), demod10(2));

% Test 11
bits11 = [1 1];
[~, sig11] = MSKmodulator(samp, bits11);
demod11 = MSKdemodulator(samp, sig11);
fprintf('Bits 11 -> demodulated: %d%d (expected 11)\n', demod11(1), demod11(2));

%% Visualize modulated signals
figure;
subplot(4,1,1);
t = (0:length(sig00)-1)/samp;
plot(t, real(sig00), 'b-', t, imag(sig00), 'r-');
title('MSK signal - bits 00');
legend('I component', 'Q component');

subplot(4,1,2);
plot(t, real(sig01), 'b-', t, imag(sig01), 'r-');
title('MSK signal - bits 01');
legend('I component', 'Q component');

subplot(4,1,3);
plot(t, real(sig10), 'b-', t, imag(sig10), 'r-');
title('MSK signal - bits 10');
legend('I component', 'Q component');

subplot(4,1,4);
plot(t, real(sig11), 'b-', t, imag(sig11), 'r-');
title('MSK signal - bits 11');
legend('I component', 'Q component');

%% Visualize demodulation process
% Using bits 10 as example
figure;
t_bit = (0:samp-1)/samp;
t_full = (0:length(sig10)-1)/samp;

% Carrier
subplot(3,2,1);
plot(t_full, cos(2*pi*0.25*t_full));
title('I carrier');

subplot(3,2,2);
plot(t_full, sin(2*pi*0.25*t_full));
title('Q carrier');

% Modulated signal
subplot(3,2,3);
plot(t_full, real(sig10));
title('I component');

subplot(3,2,4);
plot(t_full, imag(sig10));
title('Q component');

% Demodulated signal
I_demod = real(sig10) .* cos(2*pi*0.25*t_full);
Q_demod = imag(sig10) .* sin(2*pi*0.25*t_full);

subplot(3,2,5);
plot(t_full, I_demod);
title('I demodulated signal');

subplot(3,2,6);
plot(t_full, Q_demod);
title('Q demodulated signal');

%% Detailed even-bit demodulation analysis
% For bits 01, analyze second (even-numbered) bit
figure;
t_bit = (0:samp-1)/samp;
t_full = (0:length(sig01)-1)/samp;

% Extract Q component of second bit
bit_idx = samp+1:2*samp;
Q_signal = imag(sig01);
Q_bit = Q_signal(bit_idx);

% Carrier
subplot(3,1,1);
plot(t_bit, sin(2*pi*0.25*(samp+t_bit)));
title('Q carrier (second bit)');

% Q component
subplot(3,1,2);
plot(t_bit, Q_bit);
title('Q component (second bit)');

% Correlation waveform
subplot(3,1,3);
Q_carrier = sin(2*pi*0.25*(samp+t_bit));
Q_corr = Q_bit .* Q_carrier;
plot(t_bit, Q_corr);
title('Q correlation (second bit)');
corr_value = sum(Q_corr .* sin(pi*t_bit/2));
fprintf('Q correlation for second bit of 01: %.4f (negative expected for 1)\n', corr_value);
