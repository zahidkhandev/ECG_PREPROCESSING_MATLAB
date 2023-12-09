clc;
clear all;
close all;

fileName = 'ecg_70_bpm';
matFileName = strcat(fileName, '.mat');
data_path = fullfile('data/generated/normal', matFileName);
data = load(data_path);
ecg = data.ecg;

Fs = 360;
t = 1:length(ecg);
tx = t / Fs;

interval_start = 10 * Fs;
interval_end = 14 * Fs;

baseline_wander_amplitude_mV = 200;
baseline_wander_frequency = 0.4;
baseline_wander_signal = baseline_wander_amplitude_mV * sin(2 * pi * baseline_wander_frequency * tx);

powerline_amplitude_mV = 50;
powerline_frequency = 50;
powerline_signal = powerline_amplitude_mV * sin(2 * pi * powerline_frequency * tx);

noise_amplitude_mV = 20;
random_noise = noise_amplitude_mV * randn(size(ecg));

ecg_with_noise = ecg + baseline_wander_signal + powerline_signal + random_noise;

filter_order = 5;
low_cutoff = 0.5;
high_cutoff = 45;
[b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (Fs / 2), 'bandpass');
filtered_ecg = filtfilt(b, a, ecg_with_noise);

window_size = 6;
moving_avg_ecg = movmean(filtered_ecg, window_size);

total_noise = baseline_wander_signal + powerline_signal + random_noise;

signal_power_original = sum(ecg.^2);
total_noise_power = sum(total_noise.^2);
SNR_dB_original = 10 * log10(signal_power_original / total_noise_power);

noise_power_final = sum((ecg - moving_avg_ecg).^2);
SNR_DdB_final = 10 * log10(signal_power_original / noise_power_final);

disp(['SNR of the original ECG signal: ', num2str(SNR_dB_original), ' dB']);
disp(['SNR of the ECG signal after band pass filter: ', num2str(SNR_DdB_final), ' dB']);

figure;

subplot(4, 1, 1);
plot(tx(interval_start:interval_end), ecg(interval_start:interval_end), 'b');
title('Original ECG Signal (Generated)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4, 1, 2);
plot(tx(interval_start:interval_end), ecg_with_noise(interval_start:interval_end), 'r');
title('ECG Signal with Baseline Wander, Powerline Interference, and Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4, 1, 3);
plot(tx(interval_start:interval_end), filtered_ecg(interval_start:interval_end), 'm');
title('ECG Signal after Bandpass Filtering');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4, 1, 4);
plot(tx(interval_start:interval_end), moving_avg_ecg(interval_start:interval_end), 'k');
title('Denoised ECG Signal after Moving Average filter');
xlabel('Time (s)');
ylabel('Amplitude');

