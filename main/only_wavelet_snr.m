clc
clear all;
close all;

folderType = 'SR_ONLY';
folderName = '254';
subFolderName  ='00007';
fileName = strcat(folderName, subFolderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/', folderType, folderName, subFolderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);

fs = 125;  % Sampling frequency (Hz)
N = length(ecg_orig);
t = (0:N-1) / fs;


filtered_ecg = wavelet_denoise(ecg_orig);

segment_duration = 20;  

samples_start = 10 * fs;

samples_per_segment = fs * segment_duration;

ecg_segment_orig = ecg_orig(samples_start:samples_per_segment);
ecg_segment_filtered = filtered_ecg(samples_start:samples_per_segment);

t_segment = t(samples_start:samples_per_segment);

figure;
subplot(2, 1, 1);
plot(t_segment, ecg_segment_orig);
title('Original ECG Signal (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(2, 1, 2);
plot(t_segment, ecg_segment_filtered);
title('Filtered ECG Signal (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

pqrst_plot(ecg_segment_filtered, fs, t_segment);

% Calculate SNR using the custom function
snr_in_db = calculate_snr(ecg_orig, filtered_ecg);

% Display the SNR values
fprintf('SNR using MATLAB function: %.2f dB\n', snr_in_db);



