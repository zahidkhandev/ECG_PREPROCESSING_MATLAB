clc;
clear all;
close all;

% Load the original ECG signal
fileName = 'ecg_70_bpm';
matFileName = strcat(fileName, '.mat');
data_path = fullfile('data/generated/normal', matFileName);
data = load(data_path);
ecg = data.ecg;

Fs = 360;
t = 1:length(ecg);
tx = t / Fs;

% Define a 4-second interval (from 10 to 14 seconds)
interval_start = 10 * Fs;
interval_end = 14 * Fs;

% Add baseline wander
baseline_wander_amplitude_mV = 200;
baseline_wander_frequency = 0.4;
baseline_wander_signal = baseline_wander_amplitude_mV * sin(2 * pi * baseline_wander_frequency * tx);

% Add powerline interference at 50Hz
powerline_amplitude_mV = 50;
powerline_frequency = 50;
powerline_signal = powerline_amplitude_mV * sin(2 * pi * powerline_frequency * tx);

% Add random Gaussian noise
noise_amplitude_mV = 20;
random_noise = noise_amplitude_mV * randn(size(ecg));

ecg_with_noise = ecg + baseline_wander_signal + powerline_signal + random_noise;

level = 10;
wavelet_name = 'sym4';
wt = modwt(ecg_with_noise, level, wavelet_name);
wtrec = zeros(size(wt));
wtrec(4:7, :) = wt(4:7, :);

final_ecg = imodwt(wtrec, wavelet_name);

% Calculate SNR before denoising
signal_power_original = sum(ecg.^2);
total_noise_power = sum((baseline_wander_signal + powerline_signal + random_noise).^2);
SNR_dB_original = 10 * log10(signal_power_original / total_noise_power);

% Calculate SNR after denoising
signal_power_final = sum(ecg.^2);
noise_power_final = sum((ecg - final_ecg).^2);
SNR_DdB_final = 10 * log10(signal_power_final / noise_power_final);

figure;

subplot(3, 1, 1);
plot(tx(interval_start:interval_end), ecg(interval_start:interval_end), 'b');
title('Original ECG Signal (Generated)');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 2);
plot(tx(interval_start:interval_end), ecg_with_noise(interval_start:interval_end), 'r');
title('ECG Signal with Baseline Wander, Powerline Interference, and Noise');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 3);
plot(tx(interval_start:interval_end), final_ecg(interval_start:interval_end), 'k');
title('Denoised ECG Signal sym4 wavelet');
xlabel('Time (s)');
ylabel('ECG (mV)');

% Display SNR values for the 4-second interval
disp(['SNR of the original ECG signal (4-second interval): ', num2str(SNR_dB_original), ' dB']);
disp(['SNR of the ECG signal after denoising (4-second interval): ', num2str(SNR_DdB_final), ' dB']);
