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

ecg_signal = data.val(1, :);

fs = 125;  % Sampling frequency (Hz)
N = length(ecg_signal);
t = (0:N-1) / fs;

% Add some simulated noise to the ECG signal (adjust as needed)
SNR_db = 20;  % Signal-to-noise ratio in decibels
noise_power = var(ecg_signal) / (10^(SNR_db / 10));
noisy_ecg_signal = ecg_signal + sqrt(noise_power) * randn(size(ecg_signal));

% Kalman Filter
% You'll need to implement the Kalman filter here
% Kalman filter can be complex and requires state space modeling
% For simplicity, we'll use a simple moving average filter as a placeholder
window_size_kalman = 5;
filtered_ecg_kalman = movmean(noisy_ecg_signal, window_size_kalman);

% Ensemble Filter
% Combine low-pass and bandpass filters
cutoff_lp = 10;  % Low-pass cutoff frequency (Hz)
cutoff_bp_low = 0.5;  % Bandpass lower cutoff frequency (Hz)
cutoff_bp_high = 35;  % Bandpass higher cutoff frequency (Hz)

ecg_filtered_lp = lowpass(noisy_ecg_signal, cutoff_lp, fs);
ecg_filtered_bp = bandpass(noisy_ecg_signal, [cutoff_bp_low, cutoff_bp_high], fs);

% Simple ensemble filtering: Averaging
filtered_ecg_ensemble = (ecg_filtered_lp + ecg_filtered_bp) / 2;

% Define segment duration and starting sample
segment_duration = 20; % Adjust the segment duration as needed
samples_start = 10 * fs;
samples_per_segment = fs * segment_duration;

% Extract segments from the signals
ecg_segment_orig = ecg_signal(samples_start:samples_start + samples_per_segment - 1);
ecg_segment_kalman = filtered_ecg_kalman(samples_start:samples_start + samples_per_segment - 1);
ecg_segment_ensemble = filtered_ecg_ensemble(samples_start:samples_start + samples_per_segment - 1);

t_segment = t(samples_start:samples_start + samples_per_segment - 1);

% Plot the segments
figure;
subplot(3, 1, 1);
plot(t_segment, ecg_segment_orig);
title('Original ECG Signal (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t_segment, ecg_segment_kalman);
title('Kalman Filtered ECG (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t_segment, ecg_segment_ensemble);
title('Ensemble Filtered ECG (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

% Calculate SNR for the filtered signals
snr_kalman_db = snr(ecg_segment_orig, ecg_segment_kalman);
snr_ensemble_db = snr(ecg_segment_orig, ecg_segment_ensemble);

% Display the SNR values
fprintf('SNR for Kalman Filtered ECG: %.2f dB\n', snr_kalman_db);
fprintf('SNR for Ensemble Filtered ECG: %.2f dB\n', snr_ensemble_db);

pqrst_plot(ecg_segment_kalman, fs, t_segment, 'High-Pass and Low-Pass + Moving Avg')


