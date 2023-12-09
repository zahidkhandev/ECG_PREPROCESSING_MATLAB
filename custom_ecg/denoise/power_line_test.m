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

powerline_amplitude_mV = 50;
powerline_frequency = 50;
powerline_signal = powerline_amplitude_mV * sin(2 * pi * powerline_frequency * tx);

noise_amplitude_mV = 10;
random_noise = noise_amplitude_mV * randn(size(ecg));

ecg_with_noise = ecg + powerline_signal + random_noise;

total_noise = random_noise + powerline_signal;

signal_power_original = sum(ecg.^2);
noise_power_original = sum(total_noise.^2);

SNR_dB_original = 10 * log10(signal_power_original / noise_power_original);

level = 10;
wavelet_name = 'sym2';
wt = modwt(ecg_with_noise, level, wavelet_name);
wtrec = zeros(size(wt));
wtrec(4:8, :) = wt(4:8, :);

final_ecg = imodwt(wtrec, wavelet_name);

signal_power_final = sum(ecg.^2);
noise_power_final = sum((ecg - final_ecg).^2);
SNR_DdB_final = 10 * log10(signal_power_final / noise_power_final);

figure;
subplot(3, 1, 1);
plot(tx, ecg);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 2);
plot(tx, ecg_with_noise);
title('ECG Signal with Powerline Interference and Noise');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(3, 1, 3);
plot(tx, final_ecg);
title('Denoised ECG Signal');
xlabel('Time (s)');
ylabel('ECG (mV)');

disp(['SNR of the original ECG signal: ', num2str(SNR_dB_original), ' dB']);
disp(['SNR of the ECG signal after denoising: ', num2str(SNR_DdB_final), ' dB']);
