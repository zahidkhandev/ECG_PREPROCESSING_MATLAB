clc;
clear all;
close all;

fileName = 'ecg_60_bpm';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/generated/normal', matFileName);
data = load(data_path);

ecg_signal = data.ecg;

N = length(ecg_signal);
fs = 125;
t = (0:N-1) / fs;

SNR_dB = 20;
noise_power = var(ecg_signal) / (10^(SNR_dB/10));

noise = sqrt(noise_power) * randn(size(ecg_signal));

noisy_ecg_signal = ecg_signal + noise;

figure;
subplot(3,1,1);
plot(t, ecg_signal);
title('Original ECG Signal');

subplot(3,1,2);
plot(t, noisy_ecg_signal);
title('Noisy ECG Signal');


passband = [0.4 30];  % Passband frequencies (Hz)
order = 6;  % Filter order

lowpass_cutoff = passband(2);  
[b_low, a_low] = butter(order, lowpass_cutoff / (fs / 2), 'low');

highpass_cutoff = passband(1);  
[b_high, a_high] = butter(order, highpass_cutoff / (fs / 2), 'high');

b = conv(b_low, b_high);
a = conv(a_low, a_high);

ecg_denoised = filtfilt(b, a, ecg_signal);

subplot(3,1,3);
plot(t, ecg_denoised, 'g', 'DisplayName', 'Denoised ECG Signal');
xlabel('Sample Index');
ylabel('Amplitude');
title('Denoised ECG Signal');
grid on;


% Calculate the sum of squares of the ecg_signal
orig_power = sum(ecg_signal.^2);

% Calculate the sum of squares of the difference between ecg_signal and noisy_ecg_signal
noisy_orig_difference = ecg_signal - noisy_ecg_signal;
noisy_power = sum(noisy_ecg_signal.^2);

denoised_orig_difference = ecg_signal - ecg_denoised;
denoised_power = sum(ecg_denoised.^2);


% Calculate the SNR in dB
SNR_noisy = 10 * log10(orig_power / noisy_power);

SNR_denoised = 10 * log10(orig_power / denoised_power);

% Display the SNR value
fprintf('SNR Noisy (dB): %.2f\n', SNR_noisy);
fprintf('SNR Denoised (dB): %.2f\n', SNR_denoised);



