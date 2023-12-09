clc
clear all;
close all;

folderType = 'SR_ONLY';
folderName = '055';
subFolderName = '00007';
fileName = strcat(folderName, subFolderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/', folderType, folderName, subFolderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);

fs = 125;  % Sampling frequency (Hz)
N = length(ecg_orig);
t = (0:N-1) / fs;

% High-pass filtering
cutoff_hp = 0.4;  % High-pass cutoff frequency (Hz)
stopband_attenuation = 70;  % Stopband attenuation in dB

ecg_hp_filtered = highpass(ecg_orig, cutoff_hp, fs, 'Steepness', 0.80, 'StopbandAttenuation', stopband_attenuation);

% Low-pass filtering
cutoff_lp = 10;  % Low-pass cutoff frequency (Hz)
stopband_attenuation = 70;  % Stopband attenuation in dB

ecg_filtered = lowpass(ecg_hp_filtered, cutoff_lp, fs, 'Steepness', 0.80, 'StopbandAttenuation', stopband_attenuation);

% Apply a moving average filter
window_size = 5;  % You can adjust the window size as needed
filtered_ecg_ma = movmean(ecg_filtered, window_size);

segment_duration = 20;
samples_start = 10 * fs;
samples_per_segment = fs * segment_duration;

ecg_segment_orig = ecg_orig(samples_start:samples_per_segment);
ecg_filtered = ecg_filtered(samples_start:samples_per_segment);
ecg_segment_filtered_ma = filtered_ecg_ma(samples_start:samples_per_segment);

t_segment = t(samples_start:samples_per_segment);

figure;
subplot(3, 1, 1);
plot(t_segment, ecg_segment_orig);
title('Original ECG Signal (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t_segment, ecg_filtered);
title('Filtered ECG (High-Pass and Low-Pass) (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t_segment, ecg_segment_filtered_ma);
title('Filtered ECG (Moving Average) (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

pqrst_plot(ecg_filtered, fs, t_segment, 'High-Pass and Low-Pass + Moving Avg')

% Calculate SNR for the filtered signals using the custom function
snr_hp_lp_in_db = calculate_snr(ecg_segment_orig, ecg_filtered);
snr_ma_in_db = calculate_snr(ecg_segment_orig, ecg_segment_filtered_ma);

% Display the SNR values
fprintf('SNR using High-Pass and Low-Pass Filters: %.2f dB\n', snr_hp_lp_in_db);
fprintf('SNR using Moving Average Filter: %.2f dB\n', snr_ma_in_db);


