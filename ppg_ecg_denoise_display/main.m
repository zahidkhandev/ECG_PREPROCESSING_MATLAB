clc
clear all;
close all;

folderType = 'SR_ONLY';
folderName = '449';
subFolderName  ='00007';
fileName = strcat(folderName, subFolderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/', folderType, folderName, subFolderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);

ppg_orig = data.val(4, :);

fs = 125;  % Sampling frequency (Hz)
N = length(ecg_orig);
t = (0:N-1) / fs;
passband = [0.4 20];  % Passband frequencies (Hz)
order = 6;  % Filter order

lowpass_cutoff = passband(2);  
[b_low, a_low] = butter(order, lowpass_cutoff / (fs / 2), 'low');

highpass_cutoff = passband(1);  
[b_high, a_high] = butter(order, highpass_cutoff / (fs / 2), 'high');

b = conv(b_low, b_high);
a = conv(a_low, a_high);

filtered_ecg_butterworth = filtfilt(b, a, ecg_orig);

segment_duration = 20;  
samples_start = 10 * fs;
samples_per_segment = fs * segment_duration;

ecg_segment_orig = ecg_orig(samples_start:samples_per_segment);
ecg_segment_filtered_butterworth = filtered_ecg_butterworth(samples_start:samples_per_segment);
pgg_segment = ppg_orig(samples_start:samples_per_segment);

t_segment = t(samples_start:samples_per_segment);

figure;
subplot(2, 1, 1);
plot(t_segment, ecg_segment_orig);
title('Original ECG Signal (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(t_segment, ecg_segment_filtered_butterworth);
title('Filtered ECG (Butterworth) (First 10 Seconds)');
xlabel('Time (s)');
ylabel('Amplitude');

pqrst_plot(ecg_segment_filtered_butterworth, fs, t_segment, 'Butterworth')

% Calculate SNR for the filtered signals using the custom function
snr_butterworth_in_db = calculate_snr(ecg_segment_orig, ecg_segment_filtered_butterworth);

% Display the SNR values
fprintf('SNR using Butterworth Filter: %.2f dB\n', snr_butterworth_in_db);

