clc;
clear all;
close all;

fileName = '44900009m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/mimic_raw/SR_ONLY/449/00009', matFileName);
data = load(data_path);
ecg = data.val(1, :);

N = length(ecg);
Fs = 125;
tx = (0:N-1) / Fs;

ecg = resample(ecg, tx, 360);

N = length(ecg);
Fs = 360;
tx = (0:N-1) / Fs;

interval_start = 10 * Fs;
interval_end = 14 * Fs;

filter_order = 5;
low_cutoff = 0.5;
high_cutoff = 45;
[b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (Fs / 2), 'bandpass');
filtered_ecg = filtfilt(b, a, ecg);

window_size = 5;
final_ecg = movmean(filtered_ecg, window_size);

% Calculate SNR after denoising
signal_power_final = sum(ecg.^2);
noise_power_final = sum((ecg - final_ecg).^2);
SNR_DdB_final = 10 * log10(signal_power_final / noise_power_final);

subplot(2, 1, 1);
plot(tx(interval_start:interval_end), ecg(interval_start:interval_end), 'b');
title('Original ECG Signal (MIMIC)');
xlabel('Time (s)');
ylabel('ECG (mV)');

subplot(2, 1, 2);
plot(tx(interval_start:interval_end), final_ecg(interval_start:interval_end), 'k');
title('Denoised ECG');
xlabel('Time (s)');
ylabel('ECG (mV)');

disp(['SNR of the ECG signal after denoising: ', num2str(SNR_DdB_final), ' dB']);

