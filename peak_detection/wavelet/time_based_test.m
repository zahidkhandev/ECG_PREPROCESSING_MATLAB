clc;
clear all;
close all;

fileName = '101m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/bih_raw/101/', matFileName);

data = load(data_path);

ecg = data.val(1, 1:1500);

N = length(ecg);
Fs = 360;
t = (0:N-1) / Fs;

duration = N/Fs;

fs = 360;

[ecg, t] = resample(ecg, t, fs);

filter_order = 5;
low_cutoff = 0.5;
high_cutoff = 45;
[b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (Fs / 2), 'bandpass');
filtered_ecg = filtfilt(b, a, ecg);

window_size = 5;
denoised_ecg = movmean(filtered_ecg, window_size);
    
figure;

% Original ECG subplot
subplot(2, 1, 1);
plot(ecg);
title('Original ECG');
xlabel('Time (s)');
ylabel('Amplitude');

% Denoised ECG subplot
subplot(2, 1, 2);
plot(denoised_ecg);
title('Denoised ECG');
xlabel('Time (s)');
ylabel('Amplitude');


pqrst_plot(denoised_ecg, fs, t, duration);

