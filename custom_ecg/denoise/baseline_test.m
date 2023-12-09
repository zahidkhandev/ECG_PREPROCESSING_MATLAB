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

baseline_wander_amplitude_mV = 200;
baseline_wander_frequency = 0.02;

baseline_wander_signal = baseline_wander_amplitude_mV * sin(2 * pi * baseline_wander_frequency * tx);

ecg_with_baseline_wander = ecg + baseline_wander_signal;

signal_power_original = sum(ecg.^2);
noise_power_original = sum(baseline_wander_signal.^2);

SNR_dB_original = 10 * log10(signal_power_original / noise_power_original);

level = 10;
wavelet_name = 'sym8';
wt = modwt(ecg_with_baseline_wander, level, wavelet_name);
wtrec = zeros(size(wt));
wtrec(4:8, :) = wt(4:8, :);

final_ecg = imodwt(wtrec, wavelet_name);

signal_power_final = sum(ecg.^2);
noise_power_final = sum((ecg - final_ecg).^2);

SNR_dB_final = 10 * log10(signal_power_final / noise_power_final);

figure;
subplot(3, 1, 1);
plot(tx, ecg, 'b');
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 2);
plot(tx, ecg_with_baseline_wander, 'r');
title('ECG Signal with Baseline Wander Noise');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 3);
plot(tx, final_ecg, 'g');
title('ECG Signal after Baseline Wander Removal');
xlabel('Time (s)');
ylabel('ECG (mV)');

disp(['SNR of the original ECG signal: ', num2str(SNR_dB_original), ' dB']);
disp(['SNR of the ECG signal after baseline wander removal: ', num2str(SNR_dB_final), ' dB']);
